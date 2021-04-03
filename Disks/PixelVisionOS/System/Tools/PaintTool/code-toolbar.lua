
function ImageTool:CreateToolbar()


    self.tools = {

        {
            name = "pointer",
            key = Keys.V,
            toolTip = "This is the pointer"
        },
        {
            name = "select",
            key = Keys.M,
            toolTip = "This is the selection"
        },
        {
            name = "pen",
            key = Keys.B,
            toolTip = "This is the pen"
        },
        {
            name = "eraser",
            key = Keys.E,
            toolTip = "This is the eraser"
        },
        {
            name = "line",
            key = Keys.L,
            toolTip = "This is the line"
        },
        {
            name = "circle",
            key = Keys.C,
            toolTip = "This is the circle"
        },
        {
            name = "circlefill",
            key = Keys.C,
            shift = true,
            toolTip = "This is the circle fill"
        },
        {
            name = "box",
            key = Keys.R,
            toolTip = "This is the rectangle"
        },
        {
            name = "boxfill",
            key = Keys.R,
            shift = true,
            toolTip = "This is the circle rectangle"
        },
        {
            name = "eyedropper",
            key = Keys.I,
            toolTip = "This is the eye dropper"
        },
        {
            name = "fill",
            key = Keys.F,
            toolTip = "This is the fill"
        },

    }

    self.defaultTools = self:GetToolButton({"pointer", "pen", "line", "eyedropper"})

    self.toolOptions ={

        {"pointer", "select"},
        {"pen", "eraser"},
        {"line", "circle", "circlefill", "box", "boxfill"},
        {"eyedropper", "fill"}
    }


    self.toolbarPos = NewPoint(8, 16)

    self.toolBtnData = editorUI:CreateToggleGroup()
    self.toolBtnData.onAction = function(value) self:OnPickTool(value) end

    local offsetX = 0

    -- Build tools
    for i = 1, #self.defaultTools do

        offsetX = ((i - 1) * 16) + self.toolbarPos.X
        local rect = {x = offsetX, y = self.toolbarPos.Y, w = 16, h = 16}
        editorUI:ToggleGroupButton(self.toolBtnData, rect, self.defaultTools[i].name, self.defaultTools[i].toolTip .. " - shortcut: ".. tostring(self.defaultTools[i].key))
    
    end

    pixelVisionOS:RegisterUI({name = "OnUpdateToolbar"}, "UpdateToolbar", self, true)

end

function ImageTool:OnPickTool(value)


    self.lastSelection = self.toolBtnData.currentSelection

    -- editorUI:ClearGroupSelections(self.toolBtnData)

    -- local selections = editorUI:ToggleGroupSelections(self.toolBtnData)

    -- editorUI:SelectToggleButton(self.toolBtnData, value, false)
    -- print("selections", dump(selections), self.lastSelection ,value)
    -- print("Tool Picker", value, dump(self.toolBtnData))
    -- self.toolBtnData.buttons[self.toolBtnData.currentSelection].selected = false

    -- print("Ignore", self.toolBtnData.buttons[value].spriteName)

    local buttons = self:GetToolButton(self.toolOptions[value], self.toolBtnData.buttons[value].spriteName)


    local pos = NewPoint( self.toolbarPos.X + (16 * (value-1)), self.toolbarPos.Y)
    
    -- Look to see if the modal exists
    if(self.pickerModal == nil) then

        -- Create the model
        self.pickerModal = ToolPickerModal:Init(pos, buttons)

        -- Pass a reference of the editorUI to the modal
        self.pickerModal.editorUI = self.editorUI
    -- end
    else
        -- If the modal exists, configure it with the new values
        self.pickerModal:Configure(pos, buttons)--showCancel, okButtonSpriteName, cancelButtonSpriteName)
    end

    -- Open the modal
    pixelVisionOS:OpenModal(self.pickerModal, function(value) self:OnSelectTool(value) end) -- TODO need to get the last selection

end

function ImageTool:OnSelectTool()
    print("Tool selected", self.pickerModal.selection)
    editorUI:ClearGroupSelections(self.toolBtnData)
    -- local selectedTool =

    -- local index = self.toolBtnData.currentSelection
    if(self.lastSelection == nil) then
        return
    end

    local btn = self.toolBtnData.buttons[self.lastSelection]

    

    btn.selected = true
    btn.spriteName = self.pickerModal.selection
    -- editorUI:Enable(btn, true)


    -- Find the next sprite for the button
    local spriteName = btn.spriteName

    -- Change sprite button graphic
    btn.cachedMetaSpriteIds = {
        up = FindMetaSpriteId(spriteName .. "up"),
        down = FindMetaSpriteId(spriteName .. "down") ~= -1 and FindMetaSpriteId(spriteName .. "down") or FindMetaSpriteId(spriteName .. "selectedup"),
        over = FindMetaSpriteId(spriteName .. "over"),
        selectedup = FindMetaSpriteId(spriteName .. "selectedup"),
        selectedover = FindMetaSpriteId(spriteName .. "selectedover"),
        selecteddown = FindMetaSpriteId(spriteName .. "selecteddown") ~= -1 and FindMetaSpriteId(spriteName .. "selecteddown") or FindMetaSpriteId(spriteName .. "selectedover"),
        disabled = FindMetaSpriteId(spriteName .. "disabled"),
        empty = FindMetaSpriteId(spriteName .. "empty") -- used to clear the sprites
    }

    for i = 1, #self.toolBtnData.buttons do
        editorUI:Invalidate(self.toolBtnData.buttons[i])
    end

end

function ImageTool:UpdateToolbar()

    if(pixelVisionOS:IsModalActive() == true) then
        return
    end

    editorUI:UpdateToggleGroup(self.toolBtnData)

    if(Key(Keys.LeftControl) == false and Key(Keys.RightControl) == false) then

        -- TODO need to reconnect this based on a master list of keys?
        -- for i = 1, #toolKeys do
        --     if(Key(toolKeys[i], InputState.Released)) then
        --         print("Select Tool", i)
        --         -- editorUI:SelectToggleButton(self.toolBtnData, i)
        --         break
        --     end
        -- end
    end

end

function ImageTool:GetToolButton(ids, ignore)

    local buttons = {}
    local totalTools = #self.tools
    local total = #ids

    for i = 1, total do
        
        for j = 1, totalTools do

            local tmpBtn = self.tools[j]

            if(tmpBtn.name ~= ignore and tmpBtn.name == ids[i]) then

                local data = {
                    name = tmpBtn.name,
                    key = tmpBtn.key,
                    shift = tmpBtn.shift == true,
                    toolTip = tmpBtn.toolTip
                }

                table.insert(buttons, data)

            end

        end
        
    end

    return buttons

end