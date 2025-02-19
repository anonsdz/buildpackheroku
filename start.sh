#!/bin/bash
echo "🔄 Đang clone repo từ GitHub..."
git clone https://github.com/anonsdz/buildpackheroku/ 
cd buildpackheroku

echo "🔄 Đang cài đặt dependencies..."
npm install hpack https commander colors socks express axios 

echo "🔄 Đang cài đặt cloudflared..."
npm install -g cloudflared 

echo "⏳ Đang kiểm tra thông tin hệ thống..."
echo "📌 Hệ điều hành: $(uname -a)"
echo "📌 Node.js Version: $(node -v)"
echo "📌 NPM Version: $(npm -v)"
echo "📌 CPU Cores: $(nproc)"
echo "📌 Tổng RAM: $(awk '/MemTotal/ {printf \"%.2f GB\n\", $2/1024/1024}' /proc/meminfo)"

# Chạy api.js nền
node api.js &

# Vòng lặp cập nhật hệ thống mỗi giây
while true; do
    echo "📌 RAM đã sử dụng: $(free -m | awk '/Mem:/ {printf \"%.2f%% (%.2f GB)\", $3/$2 * 100.0, $3/1024}')"
    echo "📌 RAM còn trống: $(free -m | awk '/Mem:/ {printf \"%.2f%% (%.2f GB)\", $4/$2 * 100.0, $4/1024}')"
    echo "📌 CPU đang sử dụng: $(mpstat 1 1 | awk '/all/ {print 100 - $NF}')%"
    echo "📌 CPU còn trống: $(mpstat 1 1 | awk '/all/ {print $NF}')%"
    sleep 1
done &

# Giữ tiến trình chạy mãi mãi
tail -f /dev/null
