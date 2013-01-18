--
-- Mute Players Menu
--
-- Version 1.0
-- Author: The Leprechaun
-- Email: the.leprechaun.server@gmail.com
--
--

-- Check if we are a client
if CLIENT then

	-- Create a new font for the player names
    surface.CreateFont( "NameDefault",
    {
        font        = "Helvetica",
        size        = 20,
        weight      = 800
    })
	
	-- Create the console command and function
	concommand.Add("LepMute", function()	
	
	-- Variables
	local plyrs = player.GetAll()
	local FrameWidth = 500
	local FrameHeight = 350
	local windowTitle = ""
	local muteAdmins = 0
	
	-- Get window title and admin mute setting from ConVar
	if (GetConVar("lmp_mute_admins"):GetInt() > 0) then
		windowTitle = "Mute Players"
		muteAdmins = 1
	else
		windowTitle = "Mute Players - Note: Admins cannot be muted"
		muteAdmins = 0
	end
	
	-- Create the DFrame to house the stuff
	DermaFrame = vgui.Create( "DFrame" )
	DermaFrame:SetPos( (ScrW()/2)-100,(ScrH()/2)-100 )
	DermaFrame:SetWidth(FrameWidth)
	DermaFrame:SetHeight(FrameHeight)
	DermaFrame:SetTitle( windowTitle )
	DermaFrame:SetVisible( true )
	DermaFrame:SetDraggable( true )
	DermaFrame:ShowCloseButton( true )
	DermaFrame:Center()
	DermaFrame:SetDeleteOnClose(true)
	DermaFrame:MakePopup()
	
	-- Create a DPanelList. Used for it's scrollbar
	DermaScrollPanel = vgui.Create("DPanelList", DermaFrame)
	DermaScrollPanel:SetPos(6, 25)
	DermaScrollPanel:SetSize(FrameWidth-12, FrameHeight-25-6)
	DermaScrollPanel:SetSpacing(2)
	DermaScrollPanel:SetPadding(2)
	DermaScrollPanel:SetVisible(true)
	DermaScrollPanel:EnableHorizontal(false)
	DermaScrollPanel:EnableVerticalScrollbar(true)

	-- Get the size of DermaScrollPanel
	local scrollWide = DermaScrollPanel:GetWide()
	
	-- Function to create player panels and add them to DermaScrollPanel
	function CreatePlayerPanels()
	
	-- Loop through players
	for id, pl in pairs( plyrs ) do
	
			-- Create a DPanel to hold the player
			pl.PlayerPanel = vgui.Create("DPanel")
			pl.PlayerPanel:SetWide(scrollWide)
			pl.PlayerPanel:SetVisible(true)

			-- Get the width of pl.PlayerPanel
			pl.PlayerPanelWide = pl.PlayerPanel:GetWide()

			-- Create a DLabel for the players name
			pl.NameLabel = vgui.Create( "DLabel", pl.PlayerPanel )
			pl.NameLabel:SetFont("NameDefault")
			pl.NameLabel:SetText(pl:Nick())
			pl.NameLabel:SetWide(pl.PlayerPanelWide - 50)
			pl.NameLabel:SetPos(3,3)
			pl.NameLabel:SetColor(Color(0,0,0,255))

			-- Create a DImageButton for the mute icon
			pl.Mute = vgui.Create( "DImageButton", pl.PlayerPanel )
			pl.Mute:SetSize( 20, 20 )

			-- Set if the player is muted
			pl.Muted = pl:IsMuted()

			-- Set the icon the mute status of the player
			if ( pl.Muted ) then
				pl.Mute:SetImage( "icon32/muted.png" )
			else
				pl.Mute:SetImage( "icon32/unmuted.png" )
			end

			-- Function when pl.Mute is clicked
			pl.Mute.DoClick = function()

			-- Change the mute state
			pl:SetMuted( !pl.Muted )

			-- Clear our DermaScrollPanel
			DermaScrollPanel:Clear()

			-- Call the function to redraw the DermaScrollPanel
			CreatePlayerPanels()

			-- This code can probably be removed
			if ( pl.Muted ) then
				pl.Mute:SetImage( "icon32/muted.png")
				
			else
				pl.Mute:SetImage( "icon32/unmuted.png" )
			end
			end
			
			-- Add the player panel to the DermaScrollPanel
			DermaScrollPanel:AddItem(pl.PlayerPanel)

			-- Create the layout for the panel and its children
			pl.PlayerPanel:InvalidateLayout(true)
			pl.PlayerPanel.PerformLayout = function()
			pl.PlayerPanelWide = pl.PlayerPanel:GetWide()
			pl.NameLabel:SetWide(pl.PlayerPanelWide - 50)
			pl.Mute:SetPos(pl.PlayerPanelWide - 20 - 3,3)
			pl.NameLabel:SetPos(3,3)
			end
			
			-- Check if the player is and admin. If so, don't let players mute them
			-- Comment out this section to disable this feature
			if (muteAdmins) then
				if (pl:IsAdmin()) then
					pl.Mute:SetDisabled(true)
				else
					pl.Mute:SetDisabled(false)
				end
			end
			----- Admin mute disable section end ------
	end
	end
	
	-- This is the initial call to the function to draw the DermaScrollPanel
	-- This is called when the console command is run
	-- Has to be below the function, otherwise the function would be nonexistent when called
	CreatePlayerPanels()
	
end)
end


-- Check if we are a Server
if SERVER then

-- Create ConVars
CreateConVar("lmp_mute_admins", "0", {FCVAR_REPLICATED})
CreateConVar("lmp_text_command", "mute", {FCVAR_REPLICATED})

	-- Add a hook to player chat
    hook.Add("PlayerSay", "LepMutePlayers", function(Player, Text, Public)
	
		-- Get text command from ConVar
		local textCommand = "!" .. GetConVar("lmp_text_command"):GetString()
		
    	-- Check if the text starts with a !
        if Text[1] == "!" then

        	-- Make the text all lowercase
            Text = Text:lower()

            -- Check if the text is "!mute". If so, run the console command
            if Text == textCommand then
			Player:ConCommand("LepMute")
                return ""
            end
        end
    end)
end