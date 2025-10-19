#!/usr/bin/env python3
"""
ARM Cortex-M4 HAL Simulator
Simulates STM32F407VG hardware abstraction layer
"""

import socket
import struct
import threading
import time
from typing import Dict, Any

class STM32F407Simulator:
    def __init__(self):
        self.gpio_state = {
            'GPIOD': {
                12: False,  # Green LED
                13: False,  # Orange LED
                14: False,  # Red LED
                15: False,  # Blue LED
            }
        }
        self.uart_buffer = []
        self.running = True
        
    def handle_gpio_write(self, port: str, pin: int, value: bool):
        """Handle GPIO pin write operations"""
        if port in self.gpio_state and pin in self.gpio_state[port]:
            self.gpio_state[port][pin] = value
            led_names = {12: 'GREEN', 13: 'ORANGE', 14: 'RED', 15: 'BLUE'}
            if pin in led_names:
                status = 'ON' if value else 'OFF'
                print(f"[HAL-SIM] LED {led_names[pin]}: {status}")
    
    def handle_uart_write(self, data: bytes):
        """Handle UART write operations"""
        try:
            text = data.decode('utf-8')
            print(f"[UART] {text}", end='')
            self.uart_buffer.append(text)
        except UnicodeDecodeError:
            print(f"[UART-HEX] {data.hex()}")
    
    def start_gdb_server(self, port: int = 1234):
        """Start GDB server for debugging"""
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind(('localhost', port))
        server.listen(1)
        
        print(f"[HAL-SIM] GDB server listening on port {port}")
        
        while self.running:
            try:
                client, addr = server.accept()
                print(f"[HAL-SIM] GDB client connected from {addr}")
                self.handle_gdb_client(client)
            except Exception as e:
                if self.running:
                    print(f"[HAL-SIM] GDB server error: {e}")
    
    def handle_gdb_client(self, client: socket.socket):
        """Handle GDB client connection"""
        try:
            while self.running:
                data = client.recv(1024)
                if not data:
                    break
                
                # Simple GDB protocol handling
                command = data.decode('ascii', errors='ignore')
                if command.startswith('$'):
                    # Send acknowledgment
                    client.send(b'+')
                    
                    # Handle basic GDB commands
                    if 'qSupported' in command:
                        response = b'$PacketSize=1000#00'
                        client.send(response)
                    elif 'g' in command:  # Read registers
                        # Send dummy register values
                        registers = '0' * 128  # 32 registers * 4 bytes * 2 hex chars
                        response = f'${registers}#00'.encode()
                        client.send(response)
                    else:
                        # Send empty response
                        client.send(b'$#00')
                        
        except Exception as e:
            print(f"[HAL-SIM] GDB client error: {e}")
        finally:
            client.close()
    
    def run(self):
        """Run the simulator"""
        print("[HAL-SIM] STM32F407VG HAL Simulator starting...")
        print("[HAL-SIM] Simulating GPIO, UART, and basic peripherals")
        
        # Start GDB server in background
        gdb_thread = threading.Thread(target=self.start_gdb_server)
        gdb_thread.daemon = True
        gdb_thread.start()
        
        # Main simulation loop
        try:
            while self.running:
                time.sleep(0.1)
                
                # Simulate periodic tasks
                # Could add timer interrupts, ADC readings, etc.
                
        except KeyboardInterrupt:
            print("\n[HAL-SIM] Shutting down simulator...")
            self.running = False

if __name__ == "__main__":
    simulator = STM32F407Simulator()
    simulator.run()