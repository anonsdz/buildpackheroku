#!/bin/bash

echo "🔄 Đang clone repo từ GitHub..."
git clone https://github.com/anonsdz/buildpackheroku/ || { echo "❌ Lỗi khi clone repo!"; exit 1; }
cd buildpackheroku || exit

echo "🔄 Đang cài đặt dependencies..."
npm install hpack https commander colors socks express axios || { echo "❌ Lỗi khi cài đặt dependencies!"; exit 1; }

echo "🔄 Đang cài đặt cloudflared..."
npm install -g cloudflared || { echo "❌ Lỗi khi cài đặt cloudflared!"; exit 1; }

echo "⏳ Thông tin hệ thống:"
echo "📌 OS: $(uname -a)"
echo "📌 Node.js: $(node -v) | NPM: $(npm -v) | CPU Cores: $(nproc)"

# Lấy tổng RAM (GB)
total_ram=$(awk '/MemTotal/ {printf "%.2f", $2 / 1024 / 1024}' /proc/meminfo)
echo "📌 Tổng RAM: ${total_ram} GB"

# Chạy API
node api.js &

# Vòng lặp cập nhật thông tin
while true; do
    read -r total used free <<< $(free -m | awk '/Mem:/ {printf "%.2f %.2f %.2f", $2/1024, $3/1024, $4/1024}')
    used_percent=$(awk "BEGIN {printf \"%.2f\", ($used/$total) * 100}")
    free_percent=$(awk "BEGIN {printf \"%.2f\", ($free/$total) * 100}")

    # Lấy giá trị CPU đang sử dụng
    cpu_usage=$(top -bn1 | awk -F',' '/Cpu\(s\)/ {print 100 - $4}' | awk '{printf "%.2f", $1}')
    cpu_free=$(awk "BEGIN {printf \"%.2f\", 100 - $cpu_usage}")

    echo "📌 RAM đã sử dụng: ${used_percent}% (${used} GB)"
    echo "📌 RAM còn trống: ${free_percent}% (${free} GB)"
    echo "📌 CPU đang sử dụng: ${cpu_usage}%"
    echo "📌 CPU còn trống: ${cpu_free}%"

    sleep 1
done &

tail -f /dev/null
