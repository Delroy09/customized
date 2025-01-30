document.addEventListener("DOMContentLoaded", () => {
    const loginForm = document.getElementById("login-form");
    const signInButton = document.querySelector(".button-filled button");
    const errorMessage = document.getElementById("error-message");
    const rememberMe = document.getElementById("rememberMe");
    const usernameField = document.getElementById("username");
    const passwordField = document.getElementById("password");

    // stored credentials in cookies
    const storedUsername = getCookie("rememberedUsername");
    const storedPassword = getCookie("rememberedPassword");

    if (storedUsername && storedPassword) {
        usernameField.value = storedUsername;
        passwordField.value = storedPassword;
        rememberMe.checked = true;
    }

    // clear fields if "Remember Me" is unchecked
    rememberMe.addEventListener("change", () => {
        if (!rememberMe.checked) {
            usernameField.value = '';
            passwordField.value = '';
            deleteCookie("rememberedUsername");
            deleteCookie("rememberedPassword");
        }
    });

    // clear input fields on navigation back to the page
    window.addEventListener("pageshow", () => {
        if (!rememberMe.checked) {
            usernameField.value = '';
            passwordField.value = '';
        }
    });

    // login form submit
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        if (!validateFields()) {
            return;
        }

        const formData = new FormData(e.target);

        try {
            const response = await fetch('index.php', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                window.location.replace(result.redirect);
            } else {
                showError(result.error);
            }
        } catch (error) {
            console.error('Error:', error);
        }
    });

    function validateFields() {
        const username = usernameField.value.trim();
        const password = passwordField.value.trim();

        if (!username || !password) {
            showError("Please fill in all fields.");
            return false;
        }
        return true;
    }

    function showError(message) {
        errorMessage.textContent = message;
        errorMessage.style.color = "red";
        setTimeout(() => {
            errorMessage.textContent = "";
        }, 1500);
    }
});
// functions for cookies
function setCookie(name, value, days) {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    const expires = "expires=" + date.toUTCString();
    document.cookie = `${name}=${value}; ${expires}; path=/;`;
}

function getCookie(name) {
    const nameEQ = name + "=";
    const cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
        let cookie = cookies[i].trim();
        if (cookie.indexOf(nameEQ) === 0) return cookie.substring(nameEQ.length, cookie.length);
    }
    return null;
}

function deleteCookie(name) {
    document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
}

function validateLogin(username, password) {
    if (!username && !password) {
        return {
            isValid: false,
            message: 'Username and password are required.'
        };
    }
    if (!username) {
        return {
            isValid: false,
            message: 'Username is required.'
        };
    }
    if (!password) {
        return {
            isValid: false,
            message: 'Password is required.'
        };
    }
    if (!['bca', 'bvoc'].includes(username.toLowerCase())) {
        return {
            isValid: false,
            message: 'Incorrect username. Please try again.'
        };
    }
    if (password !== 'admin') {
        return {
            isValid: false,
            message: 'Incorrect password. Please try again.'
        };
    }
    return {
        isValid: true,
        message: ''
    };
}
