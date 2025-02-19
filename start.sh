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

# Kiểm tra tổng RAM
total_ram=$(grep MemTotal /proc/meminfo | awk '{printf "%.2f", $2/1024/1024}')
echo "📌 Tổng RAM: ${total_ram} GB"

# Chạy api.js nền
node api.js &

# Vòng lặp cập nhật hệ thống mỗi giây
while true; do
    used_ram=$(free -m | awk '/Mem:/ {printf "%.2f", $3/1024}')
    free_ram=$(free -m | awk '/Mem:/ {printf "%.2f", $4/1024}')
    total_ram=$(free -m | awk '/Mem:/ {printf "%.2f", $2/1024}')
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

    echo "📌 RAM đã sử dụng: $(awk "BEGIN {printf \"%.2f%% (%.2f GB)\", $used_ram/$total_ram * 100.0, $used_ram}")"
    echo "📌 RAM còn trống: $(awk "BEGIN {printf \"%.2f%% (%.2f GB)\", $free_ram/$total_ram * 100.0, $free_ram}")"
    echo "📌 CPU đang sử dụng: ${cpu_usage}%"
    echo "📌 CPU còn trống: $(awk "BEGIN {printf \"%.2f\", 100 - $cpu_usage}")%"

    sleep 1
done &

# Giữ tiến trình chạy mãi mãi
tail -f /dev/null
