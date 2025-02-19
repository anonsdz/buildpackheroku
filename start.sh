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

# Lấy tổng RAM chính xác
total_ram=$(awk '/MemTotal/ {printf "%.2f", $2 / 1024 / 1024}' /proc/meminfo)
echo "📌 Tổng RAM: ${total_ram} GB"

# Chạy api.js ở chế độ nền
node api.js &

# Vòng lặp cập nhật thông tin hệ thống mỗi giây
while true; do
    # Lấy thông tin RAM
    read -r total used free <<<$(free -m | awk '/Mem:/ {printf "%.2f %.2f %.2f", $2/1024, $3/1024, $4/1024}')
    
    # Lấy thông tin CPU chính xác hơn
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
    cpu_usage=$(echo "100 - $cpu_idle" | bc)

    # Hiển thị thông tin
    echo "📌 RAM đã sử dụng: $(echo "scale=2; $used / $total * 100" | bc)% ($used GB)"
    echo "📌 RAM còn trống: $(echo "scale=2; $free / $total * 100" | bc)% ($free GB)"
    echo "📌 CPU đang sử dụng: $cpu_usage%"
    echo "📌 CPU còn trống: $(echo "scale=2; 100 - $cpu_usage" | bc)%"

    sleep 1
done &

# Giữ tiến trình chạy mãi mãi
wait
