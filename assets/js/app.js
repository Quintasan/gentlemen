window.fbAsyncInit = function() {
  FB.init({
    appId: "605803890096460",
    cookie: true,
    xfbml: true,
    version: "v8.0"
  });
}

async function postData(url = '', data = {}) {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });
  return response.json();
}

function checkLoginState(response) {
  FB.getLoginStatus(function(response) {
    statusChangeCallback(response);
  });
}
function statusChangeCallback(response) {
  if(response.status === "connected") {
    register(response);
  }
}

function register(response) {
  postData("/register", response)
  .then(data => {
    if (data.success === true) {
      console.log("Redirecting to /host");
      window.location.replace("/host");
    } else {
      document.querySelector("#status").innerHTML = `Nie udało się zalogować, prosimy o kontakt na michal.zajac@gmail.com`;
    }

  });
}

window.addEventListener("load", function() {
});
