import argparse
import logging
from pythonosc import udp_client, dispatcher, osc_server
import threading

class OSCOrchestrator:
    def __init__(self, sc_ip, sc_port, processing_ip, processing_port, py_ip, py_port):
        self.sc_ip, self.sc_port = sc_ip, sc_port
        self.processing_ip, self.processing_port = processing_ip, processing_port
        self.py_ip, self.py_port = py_ip, py_port
        
        # Set up logging
        logging.basicConfig(level=logging.INFO, 
                            format='%(asctime)s - %(levelname)s - %(message)s')
        self.logger = logging.getLogger(__name__)
        
        # Set up OSC clients
        self.sc_client = udp_client.SimpleUDPClient(self.sc_ip, self.sc_port)
        self.processing_client = udp_client.SimpleUDPClient(self.processing_ip, self.processing_port)
        
        # Set up OSC server
        self.dispatcher = dispatcher.Dispatcher()
        self.dispatcher.map("/from_supercollider", self.handle_supercollider_message)
        self.dispatcher.map("/from_processing", self.handle_processing_message)
        self.server = osc_server.ThreadingOSCUDPServer((self.py_ip, self.py_port), self.dispatcher)
        
        # Start server thread
        self.server_thread = threading.Thread(target=self.server.serve_forever)

    def start(self):
        self.server_thread.start()
        self.logger.info("OSC Orchestrator started.")

    def handle_supercollider_message(self, address, *args):
        self.logger.info(f"Received from SuperCollider: {address}: {args}")
        # Process the message and decide whether to forward it to Processing
        self.send_to_processing(address, *args)

    def handle_processing_message(self, address, *args):
        self.logger.info(f"Received from Processing: {address}: {args}")
        # Process the message and decide whether to forward it to SuperCollider
        self.send_to_supercollider(address, *args)

    def send_to_supercollider(self, address, *args):
        self.sc_client.send_message(address, args)
        self.logger.info(f"Sent to SuperCollider: {address}: {args}")

    def send_to_processing(self, address, *args):
        self.processing_client.send_message(address, args)
        self.logger.info(f"Sent to Processing: {address}: {args}")

    def run(self):
        try: # The following block is not very important and I guess we dont really need it.
            self.start()
            while True:
                command = input("Enter command (sc/proc/quit): ").strip().lower()
                if command == 'quit':
                    break
                elif command in ['sc', 'proc']:
                    address = input("Enter OSC address: ").strip()
                    message = input("Enter message: ").strip()
                    if command == 'sc':
                        self.send_to_supercollider(address, message)
                    else:
                        self.send_to_processing(address, message)
                else:
                    print("Invalid command. Use 'sc', 'proc', or 'quit'.")
        except KeyboardInterrupt:
            self.logger.info("Keyboard interrupt received. Shutting down.")
        finally:
            self.logger.info("Shutting down orchestrator...")
            self.server.shutdown()
            self.server_thread.join()
            self.logger.info("Orchestrator shut down successfully.")

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