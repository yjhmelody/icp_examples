import {
    icp_5,
    idlFactory,
} from "../../declarations/icp_5";
import moment from "moment";
import {
    Actor,
} from "@dfinity/agent";

async function post() {
    let btn = document.getElementById("post");
    btn.disable = true;
    let message = document.getElementById("message");
    let text = message.value;
    console.log("post:", text);
    try {
        await icp_5.post(text);
    } catch (err) {
        console.log("Error occurred when post:", err);
        message.value = "";
    }
    btn.disable = false;
}

function createBlogLayout(post) {
    let block = document.createElement("blockquote");
    let author = document.createElement("p");
    let time = document.createElement("p");
    let blog = document.createElement("p");
    let postAuthor = post.author[0] ? post.author[0].toString() : "anonymous";
    author.innerText = postAuthor;
    time.innerText = formatTime(post.time);
    blog.innerText = post.text.toString();
    block.appendChild(author);
    block.appendChild(time);
    block.appendChild(blog);
    return block;
}

function createFollowLayout(name, id) {
    let block = document.createElement("p");
    let follow = document.createElement("a");
    if (name == null) {
        follow.innerText = `${id.toString()}`;
    } else {
        follow.innerText = `${name.toString()}(${id.toString()})`;
    }
    follow.href = `https://${id}.ic0.app`;
    block.appendChild(follow);
    return block;
}

async function loadFollows() {
    let followIds = await icp_5.follows();
    let followsLayout = document.querySelector("#follows");
    followsLayout.replaceChildren([]);
    for (let id of followIds) {
        try {
            let name = await queryFollowName(id);
            followsLayout.appendChild(createFollowLayout(name, id))
        } catch (err) {
            console.error("Error occurred when query follow:", err);
            followsLayout.appendChild(createFollowLayout(null, id))
        }
    }
}

async function queryFollowName(canisterId) {
    let actor = Actor.createActor(idlFactory, {
        canisterId: canisterId,
    });
    let name = await actor.get_name();
    console.log("query name:", canisterId, name);
    return name;
}

function formatTime(time) {
    return moment(Number(time) / 1000000).format('MMMM Do YYYY, h:mm:ss a');
}

let postNum = 0;
async function loadPosts() {
    let postsSection = document.getElementById("posts");
    try {
        let posts = await icp_5.posts(0);
        if (postNum == posts.length) {
            return;
        }
        postNum = posts.length;
        postsSection.replaceChildren([]);
        for (let post of posts) {
            console.log(post);
            let blog = createBlogLayout(post);
            postsSection.appendChild(blog);
        }
    } catch (err) {
        console.log("Error occurred when load posts:", err);
    }
}


let followedPostNum = 0;
async function loadFollowedPosts() {
    let postsSection = document.getElementById("timeline");
    try {
        let posts = await icp_5.timeline(0);
        if (followedPostNum == posts.length) {
            return;
        }
        followedPostNum = posts.length;
        postsSection.replaceChildren([]);
        for (let post of posts) {
            let postLine = document.createElement("p");
            postLine.innerText = post.text;
            postsSection.appendChild(postLine)
        }
    } catch (err) {
        console.log("Error occurred when load posts:", err);
    }
}

function load() {
    let postBtn = document.getElementById("post");
    postBtn.onclick = post;
    loadPosts();
    loadFollowedPosts();
    loadFollows();
    setInterval(loadPosts, 3000);
    setInterval(loadFollows, 3000);
    setInterval(loadFollowedPosts, 3000);
}

window.onload = load;