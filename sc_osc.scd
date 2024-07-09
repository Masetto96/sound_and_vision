(
// Initialize the server
s.boot;

// Define OSC client and server
~pythonClient = NetAddr("127.0.0.1", 5000);  // Python's default listening port
~oscResponder = OSCFunc({ |msg, time, addr, recvPort|
    var address = msg[0];
    var args = msg[1..];
    "Received from Python: % %".format(address, args).postln;
    // Add your custom logic here to process incoming messages
}, '/from_processing');

// Function to send messages to Python
~sendToPython = { |address ... args|
    ~pythonClient.sendMsg(address, *args);
    "Sent to Python: % %".format(address, args).postln;
};

// Example usage
~sendToPython.("/from_supercollider", "Hello python this is supercollider");

// GUI for sending messages
Window.new("OSC Sender", Rect(200, 200, 300, 100)).front.layout_(
    VLayout(
        TextView().string_("Type your message here"),
        Button()
            .states_([["Send"]])
            .action_({ |but|
                var msg = but.parent.children[0].string;
                ~sendToPython.("/from_supercollider", msg);
            })
    )
);

// Cleanup function
CmdPeriod.doOnce({
    ~oscResponder.free;
    "OSC responder freed.".postln;
});
)