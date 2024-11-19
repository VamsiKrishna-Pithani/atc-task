// Display an alert when the button is clicked
function showMessage() {
    alert("Hello! This is a JavaScript alert.");
}

// Change the text content dynamically
function changeGreeting() {
    const heading = document.querySelector("h1");
    heading.textContent = "You clicked the button!";
    heading.style.color = "#ff7f50"; // Change the color for emphasis
}

// Attach event listeners to the button
document.addEventListener("DOMContentLoaded", () => {
    const button = document.querySelector("button");

    button.addEventListener("click", () => {
        showMessage(); // Show an alert
        changeGreeting(); // Update the heading
    });
});
