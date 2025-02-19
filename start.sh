#!/bin/bash

echo "🔄 Đang clone repo từ GitHub..."
if ! git clone https://github.com/anonsdz/buildpackheroku/; then
    echo "❌ Lỗi khi clone repo! Kiểm tra kết nối mạng."
    exit 1
fi
cd buildpackheroku || exit

echo "🔄 Đang cài đặt dependencies..."
if ! npm install hpack https commander colors socks express axios; then
    echo "❌ Lỗi khi cài đặt dependencies!"
    exit 1
fi

echo "🔄 Đang cài đặt cloudflared..."
if ! npm install -g cloudflared; then
    echo "❌ Lỗi khi cài đặt cloudflared!"
    exit 1
fi

echo "⏳ Đang kiểm tra thông tin hệ thống..."
echo "📌 Hệ điều hành: $(uname -a)"
echo "📌 Node.js Version: $(node -v)"
echo "📌 NPM Version: $(npm -v)"
echo "📌 CPU Cores: $(nproc)"

# Lấy tổng RAM (GB)
total_ram=$(awk '/MemTotal/ {printf "%.2f", $2 / 1024 / 1024}' /proc/meminfo)
echo "📌 Tổng RAM: ${total_ram} GB"

# Chạy api.js ở chế độ nền
node api.js &

# Vòng lặp cập nhật thông tin hệ thống mỗi giây
while true; do
    # Lấy thông tin RAM (GB)
    read -r total used free <<< $(free -m | awk '/Mem:/ {printf "%.2f %.2f %.2f", $2/1024, $3/1024, $4/1024}')
    used_percent=$(awk "BEGIN {printf \"%.2f\", ($used/$total) * 100}")
    free_percent=$(awk "BEGIN {printf \"%.2f\", ($free/$total) * 100}")

    # Lấy thông tin CPU (%)
    cpu_idle=$(top -bn1 | awk '/Cpu\(s\)/ {print $8}')
    cpu_usage=$(awk "BEGIN {printf \"%.2f\", 100 - $cpu_idle}")
    cpu_free=$(awk "BEGIN {printf \"%.2f\", $cpu_idle}")

    echo "📌 RAM đã sử dụng: ${used_percent}% (${used} GB)"
    echo "📌 RAM còn trống: ${free_percent}% (${free} GB)"
    echo "📌 CPU đang sử dụng: ${cpu_usage}%"
    echo "📌 CPU còn trống: ${cpu_free}%"

    sleep 1
done &

# Giữ tiến trình chạy mãi mãi
tail -f /dev/null
