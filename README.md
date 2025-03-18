# Local Cloud API

A lightweight, self-hosted cloud API service that runs locally on your machine.

## 📋 Overview

Local Cloud API provides cloud-like functionality without requiring external services. This application is designed to be easy to set up and use, with a simple installation process and automatic startup options.

## ✨ Features

- **Self-hosted**: Run entirely on your local machine
- **FastAPI Backend**: Utilizing modern Python FastAPI framework
- **Cross-platform**: Compatible with Windows, Linux, and macOS
- **Easy Installation**: Single-script setup process
- **Startup Configuration**: Optionally run on system startup

## 🚀 Quick Start

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/navaura/LCA.git
   chmod +x start.sh
   ```

2. Make the setup script executable:
   ```bash
   chmod +x start.sh
   ```

3. Run the setup script:
   ```bash
   ./start.sh
   ```

4. The script will automatically:
   - Extract necessary files
   - Set up a Python virtual environment
   - Install dependencies
   - Offer to configure startup settings
   - Launch the application

### After Installation

On subsequent runs, the script provides a management menu:

1. Run the application
2. Toggle startup setting
3. Reinstall/repair installation
4. Exit

## 🔧 Technical Details

### Dependencies

- Python 3.6+
- FastAPI
- Uvicorn
- Python-multipart
- Bcrypt
- Psutil

### Architecture

The application uses a FastAPI backend that serves as your local cloud interface. Configuration data is stored locally and securely.

## 🔒 Security

All data remains on your local machine - no external services are used.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Development

To contribute to the development:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
