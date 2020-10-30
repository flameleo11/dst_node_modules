local easing = require("easing")
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"

local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout

local sformat = import("common").sformat

local DST_ROLES = DST_CHARACTERLIST
local MOD_ROLES = MODCHARACTERLIST
------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}

this.key_inited = this.key_inited or {}
this.key_down_count = this.key_down_count or {}


this.selected_ents = this.selected_ents or {}
this.color = {x = 1, y = 1, z = 1}

local b_debug = true
local UPDATE_MS_INTERVAL = 1
local DEFAULT_FADE_TIME = 10






------------------------------------------------------------
-- tools
------------------------------------------------------------

-- todo dispatcher
-- AddComponentPostInit
-- AddClassPostConstruct

local action_queue_key = GetKeyFromConfig("action_queue_key")
--maybe i won't need this one day...
local use_control = TheInput:GetLocalizedControl(0, CONTROL_FORCE_TRADE) == STRINGS.UI.CONTROLSSCREEN.INPUTS[1][action_queue_key]
action_queue_key = use_control and CONTROL_FORCE_TRADE or action_queue_key
TheInput.IsAqModifierDown = use_control and TheInput.IsControlPressed or TheInput.IsKeyDown
local always_clear_queue = GetModConfigData("always_clear_queue")
AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= _G.ThePlayer then return end
    ThePlayer = _G.ThePlayer
    TheWorld = _G.TheWorld
    ActionQueuerInit()

    local PlayerControllerOnControl = self.OnControl
    self.OnControl = function(self, control, down)
        local mouse_control = mouse_controls[control]
        if mouse_control ~= nil then
            if down then
                if TheInput:IsAqModifierDown(action_queue_key) then
                    local target = TheInput:GetWorldEntityUnderMouse()
                    if target and target:HasTag("fishable") and not inst.replica.rider:IsRiding()
                      and inst.replica.inventory:EquipHasTag("fishingrod") then
                        ActionQueuer:StartAutoFisher(target)
                    elseif not ActionQueuer.auto_fishing then
                        ActionQueuer:OnDown(mouse_control)
                    end
                    return
                end
            else
                ActionQueuer:OnUp(mouse_control)
            end
        end
        PlayerControllerOnControl(self, control, down)
        if down and ActionQueuer.action_thread and not ActionQueuer.selection_thread and InGame()
          and (interrupt_controls[control] or mouse_control ~= nil and not TheInput:GetHUDEntityUnderMouse()) then
            ActionQueuer:ClearActionThread()
            if always_clear_queue or control == CONTROL_ACTION then
                ActionQueuer:ClearSelectedEntities()
            end
        end
    end
    local PlayerControllerIsControlPressed = self.IsControlPressed
    self.IsControlPressed = function(self, control)
        if control == CONTROL_FORCE_INSPECT and ActionQueuer.action_thread then return false end
        return PlayerControllerIsControlPressed(self, control)
    end
end)

-- todo shift+alt +click recipe to add plan
AddClassPostConstruct("components/builder_replica", function(self)
    local BuilderReplicaMakeRecipeFromMenu = self.MakeRecipeFromMenu
    self.MakeRecipeFromMenu = function(self, recipe, skin)
        last_recipe, last_skin = recipe, skin
        if not ActionQueuer.action_thread and TheInput:IsAqModifierDown(action_queue_key)
          and not recipe.placer and self:CanBuild(recipe.name) then
            ActionQueuer:RepeatRecipe(self, recipe, skin)
        else
            BuilderReplicaMakeRecipeFromMenu(self, recipe, skin)
        end
    end
    local BuilderReplicaMakeRecipeAtPoint = self.MakeRecipeAtPoint
    self.MakeRecipeAtPoint = function(self, recipe, pt, rot, skin)
        last_recipe, last_skin = recipe, skin
        BuilderReplicaMakeRecipeAtPoint(self, recipe, pt, rot, skin)
    end
end)

AddComponentPostInit("highlight", function(self, inst)
    local HighlightHighlight = self.Highlight
    self.Highlight = function(self, ...)
        if ActionQueuer.selection_thread or ActionQueuer:IsSelectedEntity(inst) then return end
        HighlightHighlight(self, ...)
    end
    local HighlightUnHighlight = self.UnHighlight
    self.UnHighlight = function(self)
        if ActionQueuer:IsSelectedEntity(inst) then return end
        HighlightUnHighlight(self)
    end
end)


return _M;