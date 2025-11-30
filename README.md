# 🏥 Egypt Health Analytics - Comprehensive Setup Guide

<div align="right">

![Python](https://img.shields.io/badge/Python-3.8%2B-blue)
![Azure](https://img.shields.io/badge/Azure-Synapse-0078D4)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success)

</div>

## 📚 Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Setup](#quick-setup)
- [Detailed Setup](#detailed-setup)
- [Database Configuration](#database-configuration)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

## 🎯 Overview

This guide aims to help you set up the Egypt Health Analytics Platform completely, from initial installation to final operation.

### Available Features
- 📊 Interactive dashboards
- 👥 Patient data management
- 🗓 Appointment system
- 📍 Geographical analytics
- 📈 Advanced reports

## ⚙ Prerequisites

### System Requirements
| Component | Version | Notes |
|-----------|---------|-------|
| Python | 3.8+ | Required for runtime |
| pip | 20.0+ | Package manager |
| Git | 2.25+ | Version control (optional) |

### Required Azure Services
| Service | Purpose | Tier |
|---------|---------|------|
| Azure Synapse Analytics | Primary database | Serverless |
| Azure Blob Storage | Storage & SQL files | Standard LRS |
| Azure Active Directory | Authentication | Free |

## 🚀 Quick Setup

### 1. Clone and Setup
```bash
# Clone repository
git clone https://github.com/egypt-health/analytics-platform.git
cd analytics-platform

# Create virtual environment
python -m venv health_env

# Activate environment
# Windows:
health_env\Scripts\activate
# Unix/MacOS:
source health_env/bin/activate

# Install dependencies
pip install -r requirements.txt
