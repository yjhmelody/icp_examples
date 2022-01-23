import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor {
    public type Message = {
        text: Text;
        author: ?Text;
        time: Time.Time;
    };

    public type Microblog = actor {
        setOwner: shared(?Principal) -> async();
        follow: shared(Principal) -> async ();
        follows: shared query() -> async [Principal];
        post: shared(Text) -> async ();
        posts: shared query (Time.Time) -> async [Message];
        timeline: shared(Time.Time) -> async [Message];
        set_name: shared(Text) -> async ();
        get_name: shared query() -> async ?Text;
    };

    stable var followed: List.List<Principal> = List.nil();
    stable var messages: List.List<Message> = List.nil();
    // The controller id
    stable var principal: ?Principal = null;
    stable var name: ?Text = null;

    func checkId(msg: {caller: Principal } ) {
        if (principal != null) {
            assert(?msg.caller == principal);
        }
    };

    public shared(msg) func setOwner(id: ?Principal): async () {
        checkId(msg);
        if (id != null) {
            principal := id;
        } else {
            principal := ?msg.caller;
        }
    };

    public shared(msg) func set_name(n: Text): async () {
        checkId(msg);
        name := ?n;
    };

    public shared query func get_name(): async ?Text {
        name
    };

    public shared(msg) func follow(id: Principal): async () {
        checkId(msg);
        followed := List.push(id, followed);
    };

    public shared query func follows(): async [Principal] {
        List.toArray(followed)
    };

    public shared (msg) func post(text: Text): async () {
        checkId(msg);
        let now = Time.now();
        let m: Message = {
            text = text;
            author = name;
            time = now;
        };
        messages := List.push(m, messages);
    };

    public shared query func posts(since: Time.Time): async [Message] {
        List.toArray(List.filter(messages, func (msg: Message): Bool {
            msg.time >= since
        }))
    };

    public shared func timeline(since: Time.Time): async [Message] {
        var all: List.List<Message> = List.nil();

        for (id in Iter.fromList(followed)) {
            let canister: Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg, all)
            }
        };

        List.toArray(all)
    };
};
