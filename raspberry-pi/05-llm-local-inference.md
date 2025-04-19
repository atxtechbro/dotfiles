# Step 1: Install llama.cpp
sudo apt update
sudo apt install -y build-essential cmake git

# Clone and build llama.cpp
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
make -j$(nproc)

