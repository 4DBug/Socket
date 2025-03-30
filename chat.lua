local Socket = loadstring(game:HttpGet("https://socket.bug.tools/"))()

local Channel = Socket.Connect(0xC0FFEE)

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Chat = PlayerGui:FindFirstChild("Chat")

local Received = {}

if Chat then
	local Logs = Chat.Frame.ChatChannelParentFrame.Frame_MessageLogDisplay.Scroller
	
	Logs.ChildAdded:Connect(function(Message)
		local DisplayName = string.sub(Message:WaitForChild("TextLabel").TextButton.Text, 2, -3)
		local Content = Message.TextLabel.Text

		Received[DisplayName] = Received[DisplayName] or {}
		table.insert(Received[DisplayName], Message.TextLabel)

		if DisplayName == LocalPlayer.DisplayName then
			Message.TextLabel:GetPropertyChangedSignal("Text"):Connect(function()
				Channel:Send(Message.TextLabel.Text, Content)
			end)
		end
	end)

	Channel.OnMessage:Connect(function(Player, Filtered, Content)
		pcall(function()
			local BubbleChat = PlayerGui:FindFirstChild("BubbleChat")

			if BubbleChat then
				local Result

				for _, Billboard in next, BubbleChat:GetChildren() do
					if Billboard.Adornee.Parent == Player.Character then
						local Maximum = -math.huge

						for _, Bubble in next, Billboard.BillboardFrame:GetChildren() do
							if Bubble.Name == "ChatBubble" then
								local Position = Bubble.Position.Y.Offset

								if Maximum < Position then
									Result = Bubble
								end

								Maximum = math.max(Maximum, Position)
							end
						end
					end
				end

				Result.BubbleText.Text = Content:gsub("^%s+", ""):gsub('(<font dir="ltr">.+</font>)', "")
			end
		end)

		pcall(function()
			local Bubbles = CoreGui.ExperienceChat.bubbleChat["BubbleChat_" .. Player.UserId].BubbleChatList
			local Maximum = 0

			for _, Bubble in next, Bubbles:GetChildren() do
				if Bubble:IsA("Frame") then
					Maximum = math.max(Maximum, tonumber(string.sub(Bubble.Name, 7, -1)))
				end
			end

			Bubbles["Bubble" .. Maximum].ChatBubbleFrame.Text.Text = Content:gsub('(<font dir="ltr">.+</font>)', "")
		end)

		pcall(function()
			for Index, Message in next, Received[Player.DisplayName] do
				if Message.Text == Filtered then
					Message.Text = Content
					Message.TextButton.TextColor3 = Color3.new(1, 1, 1)

					Received[Player.DisplayName] = {}
				end
			end
		end)
	end)
else
	TextChatService.OnIncomingMessage = function(Message)
		if Message.TextSource and Message.TextSource.UserId == LocalPlayer.UserId then
			if not string.find(Message.Text, "#") then
				Received[Message.MessageId] = Message.Text
			else
				Channel:Send(Message.MessageId, Received[Message.MessageId])
			end
		end
	end

	Channel.OnMessage:Connect(function(Player, MessageId, Content)
		pcall(function()
			local Message = CoreGui.ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView:WaitForChild(MessageId).TextMessage.BodyText
			local Content = string.format("%s: %s", Player.DisplayName, Content)
			Message.Text = Content

			Message:GetPropertyChangedSignal("Text"):Once(function()
				Message.Text = Content
			end)
		end)

		pcall(function()
			CoreGui.ExperienceChat.bubbleChat["BubbleChat_" .. Player.UserId].BubbleChatList:WaitForChild("Bubble" .. MessageId).ChatBubbleFrame.Text.Text = string.sub(Content, # Player.DisplayName + 3, -1)
		end)
	end)
end
