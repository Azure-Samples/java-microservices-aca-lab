"use strict";

var usernamePage = document.querySelector("#username-page");
var chatPage = document.querySelector("#chat-page");
var usernameForm = document.querySelector("#usernameForm");
var messageForm = document.querySelector("#messageForm");
var messageInput = document.querySelector("#message");
var messageArea = document.querySelector("#messageArea");
var connectingElement = document.querySelector(".connecting");

var socket = null;
var username = null;

var colors = [
  "#2196F3",
  "#32c787",
  "#00BCD4",
  "#ff5652",
  "#ffc107",
  "#ff85af",
  "#FF9800",
  "#39bbb0",
  "#fcba03",
  "#fc0303",
  "#de5454",
  "#b9de54",
  "#54ded7",
  "#54ded7",
  "#1358d6",
  "#d611c6",
];

function connect(event) {
  username = document.querySelector("#name").value.trim();
  if (username) {
    usernamePage.classList.add("hidden");
    chatPage.classList.remove("hidden");

    // Create a register WebSocket connection
    var protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    var socketUrl = protocol + '//' + window.location.host + '/websocket';
    console.log("WebSocket server URL: ", socketUrl);
    socket = new WebSocket(socketUrl);

    // Set up event listeners
    socket.onopen = onConnected;
    socket.onmessage = onMessageReceived;
    socket.onerror = onError;
    socket.onclose = onClosed;
  }
  event.preventDefault();
}

function onConnected() {
  console.log("Connected to WebSocket server.")
  // Send a join message to the server once connected
  const joinMessage = JSON.stringify({ sender: username, type: "JOIN" });
  socket.send(joinMessage);

  connectingElement.classList.add("hidden");
}

function onClosed(event) {
  if (event.wasClean) {
    console.log("[close] Connection closed cleanly, code= " + event.code + ", reason= " + event.reason);
  } else {
    console.log("[close] Connection died");
  }
}

function onError(error) {
  console.log("Could not connect to WebSocket! Error: ", error);
  connectingElement.textContent =
    "Could not connect to WebSocket! Please refresh the page and try again or contact your administrator.";
  connectingElement.style.color = "red";
}

function send(event) {
  var messageContent = messageInput.value.trim();
  console.log("Send message: " + messageContent);

  if (messageContent && socket) {
    var chatMessage = {
      sender: username,
      content: messageInput.value,
      type: "CHAT",
    };
    addMessage(chatMessage);

    socket.send(JSON.stringify(chatMessage));
    console.log("Sent message: " + messageContent);
    messageInput.value = "";
  }
  event.preventDefault();
}

/**
 * Handles the received message and updates the chat interface accordingly.
 * param {Object} payload - The payload containing the message data.
 */
function onMessageReceived(payload) {
  var message = JSON.parse(payload.data);
  addMessage(message)
  messageArea.scrollTop = messageArea.scrollHeight;
}

function addMessage(message){
  var messageElement = document.createElement("li");

  if (message.type === "JOIN") {
    message.content = message.sender + " joined!";
  } else if (message.type === "LEAVE") {
    message.content = message.sender + " left!";
  } else {
    var usernameElement = document.createElement("span");
    var usernameText = document.createTextNode(message.sender);
    usernameElement.appendChild(usernameText);
    messageElement.appendChild(usernameElement);
    // * update
    usernameElement.style["color"] = getAvatarColor(message.sender);
    //* update end
  }

  var textElement = document.createElement("p");
  var messageText = document.createTextNode(message.content);
  textElement.appendChild(messageText);

  messageElement.appendChild(textElement);
  // * update
  if (message.sender === username && message.type !== "JOIN") {
    // Add a class to float the message to the right
    messageElement.classList.add("own-message");
  } else if (message.type === "JOIN" || message.type === "LEAVE") {
    messageElement.classList.add("event-message");
  }
  messageArea.appendChild(messageElement);
}

function getAvatarColor(messageSender) {
  var hash = 0;
  for (var i = 0; i < messageSender.length; i++) {
    hash = 31 * hash + messageSender.charCodeAt(i);
  }

  var index = Math.abs(hash % colors.length);
  return colors[index];
}

usernameForm.addEventListener("submit", connect, true);
messageForm.addEventListener("submit", send, true);
