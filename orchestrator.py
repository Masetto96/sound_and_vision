import argparse
import logging
import threading
from queue import Queue
import time
from pythonosc import udp_client, dispatcher, osc_server

class OSCOrchestrator:
    def __init__(self, sc_ip, sc_port, processing_ip, processing_port, py_ip, py_port):
        self.sc_ip, self.sc_port = sc_ip, sc_port
        self.processing_ip, self.processing_port = processing_ip, processing_port
        self.py_ip, self.py_port = py_ip, py_port
        
        # Set up logging
        self.logger = logging.getLogger(__name__)
        
        # Set up OSC clients
        self.sc_client = udp_client.SimpleUDPClient(self.sc_ip, self.sc_port)
        self.processing_client = udp_client.SimpleUDPClient(self.processing_ip, self.processing_port)
        
        # Set up OSC server with improved dispatcher
        self.dispatcher = dispatcher.Dispatcher()
        self._setup_handlers()
        self.server = osc_server.ThreadingOSCUDPServer((self.py_ip, self.py_port), self.dispatcher)
        
        # Message queues for thread-safe communication
        self.sc_queue = Queue()
        self.processing_queue = Queue()
        
        # Start threads
        self.server_thread = threading.Thread(target=self.server.serve_forever)
        self.sc_sender_thread = threading.Thread(target=self._sc_sender_loop) # each thread will run a while loop and keep sending all the messages in the queue
        self.processing_sender_thread = threading.Thread(target=self._processing_sender_loop)

    def _setup_handlers(self):
        """
        Define the addresses here with the relative function as handler.
        """
        # Specific handlers for moiré pattern
        self.dispatcher.map("/moire/rotation", self._handle_moire_rotation)
        self.dispatcher.map("/moire/density", self._handle_moire_density)
        # self.dispatcher.map("/moire/size", self._handle_moire_size)
        # self.dispatcher.map("/moire/color", self._handle_moire_color)
        
        # Default handler for unrecognized addresses
        self.dispatcher.set_default_handler(self._handle_default)


    def _handle_moire_rotation(self, address, *args):
        try:
            rotation = float(args[0])
            self.logger.debug(f"Moire rotation: {rotation}")
            self.processing_queue.put((address, (rotation,)))
        except (ValueError, IndexError) as e:
            self.logger.error(f"Invalid moire rotation value: {e}")

    def _handle_moire_density(self, address, *args):
        try:
            density = int(args[0])
            self.logger.debug(f"Moire density: {density}")
            self.sc_queue.put((address, (density,)))
        except (ValueError, IndexError) as e:
            self.logger.error(f"Invalid moire density value: {e}")

    # def _handle_moire_size(self, address, *args):
    #     try:
    #         size = float(args[0])
    #         self.logger.debug(f"Moire size: {size}")
    #         self.processing_queue.put((address, (size,)))
    #     except (ValueError, IndexError) as e:
    #         self.logger.error(f"Invalid moire size value: {e}")

    # def _handle_moire_color(self, address, *args):
    #     try:
    #         if len(args) != 3:
    #             raise ValueError("Color should have 3 values (R, G, B)")
    #         color = tuple(map(int, args))
    #         self.logger.debug(f"Moire color: {color}")
    #         self.processing_queue.put((address, color))
    #     except (ValueError, IndexError) as e:
    #         self.logger.error(f"Invalid moire color value: {e}")

    def _handle_default(self, address, *args):
        self.logger.warning(f"Received message with unhandled address: {address}")

    def _sc_sender_loop(self):
        while True:
            address, args = self.sc_queue.get()
            self.sc_client.send_message(address, args)
            self.logger.info(f"Sent to SuperCollider: {address}: {args}")

    def _processing_sender_loop(self):
        while True:
            address, args = self.processing_queue.get()
            self.processing_client.send_message(address, args)
            self.logger.info(f"Sent to Processing: {address}: {args}")

    def _start(self):
        self.server_thread.start()
        self.sc_sender_thread.start()
        self.processing_sender_thread.start()
        self.logger.info("OSC Orchestrator started.")

    def run(self):
        try:
            self._start()
            while True:
                command = input("Enter command (sc/proc/quit): ").strip().lower()
                if command == 'quit':
                    break
        except KeyboardInterrupt:
            self.logger.info("Keyboard interrupt received. Shutting down.")
        finally:
            self.logger.info("Shutting down orchestrator...")
            self.server.shutdown()  
            self.server_thread.join()
            # Terminate sender threads
            self.sc_sender_thread.join(timeout=1)
            self.processing_sender_thread.join(timeout=1)
            self.logger.info("Orchestrator shut down successfully.") # TODO: thats not actually what happen, I mean it does not exit

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--sc-ip", default="127.0.0.1", help="SuperCollider IP")
    parser.add_argument("--sc-port", type=int, default=57120, help="SuperCollider port")
    parser.add_argument("--processing-ip", default="127.0.0.1", help="Processing IP")
    parser.add_argument("--processing-port", type=int, default=12000, help="Processing port")
    parser.add_argument("--py-ip", default="127.0.0.1", help="Python IP")
    parser.add_argument("--py-port", type=int, default=5000, help="Python port")
    parser.add_argument("--log-level", default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"], help="Set the logging level")
    args = parser.parse_args()

    logging.basicConfig(level=getattr(logging, args.log_level),
                        format='%(asctime)s - %(levelname)s - %(message)s')
    logger = logging.getLogger(__name__)

    logger.info(f"Starting OSC Orchestrator")
    logger.info(f"SuperCollider: {args.sc_ip}:{args.sc_port}")
    logger.info(f"Processing: {args.processing_ip}:{args.processing_port}")
    logger.info(f"Python: {args.py_ip}:{args.py_port}")
    
    orchestrator = OSCOrchestrator(args.sc_ip, args.sc_port, 
                                   args.processing_ip, args.processing_port, 
                                   args.py_ip, args.py_port)
    orchestrator.run()