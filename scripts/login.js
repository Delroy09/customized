document.addEventListener("DOMContentLoaded", () => {
    const loginForm = document.getElementById("login-form");
    const errorMessage = document.getElementById("error-message");

    loginForm.addEventListener("submit", (event) => {
        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value.trim();

        errorMessage.textContent = "";

        if (username === "") {
            errorMessage.textContent = "Username is required.";
            event.preventDefault();
            return;
        }

        if (password === "") {
            errorMessage.textContent = "Password is required.";
            event.preventDefault();
            return;
        }

        if (username !== 'bca' && username !== 'bvoc') {
            errorMessage.textContent = "Incorrect Username. Please try again";
            event.preventDefault();
            return;
        } else if (password !== 'admin') {
            errorMessage.textContent = "Incorrect Password. Please try again";
            event.preventDefault();
            return;
        }
    });
});
