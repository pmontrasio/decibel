// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let uuid = document.getElementById("uuid").value;
let channel = socket.channel("rooms:" + uuid, {});
let dbmContainer = document.getElementById("dbm");
let opts = {
  lines: 12,
  angle: 0.0,
  lineWidth: 0.44,
  pointer: {
    length: 0.7,
    strokeWidth: 0.035,
    color: "#000000"
  },
  limitMax: "true",
  percentColors: [[0.0, "#a9d70b" ], [0.50, "#f9c802"], [1.0, "#ff0000"]],
  strokeColor: "#E0E0E0",
  generateGradient: true
};
let target = document.getElementById("gauge");
let gauge = new Gauge(target).setOptions(opts);
gauge.maxValue = 100;
gauge.animationSpeed = 1;
gauge.set(0.0);
window.gauge_xy = gauge;

channel.on("dbm", payload => {
  var dbm = payload.dbm;
  if (dbm <= 0.0) {
    let dbmString = "" + dbm;
    let decimalPointPosition = dbmString.indexOf(".");
    if (decimalPointPosition == -1) {
      dbmContainer.textContent = dbmString + ".0 dBm";
    } else {
      dbmContainer.textContent = dbmString.substring(0, 5) + " dBm";
    }
    gauge.set(-dbm);
  }
});

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp); })
  .receive("error", resp => { console.log("Unable to join", resp); });


export default socket;
