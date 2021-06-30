-- luacheck: globals hs
local obj = {}

-- Metadata
obj.name = "FocusHighlight"
obj.version = "0.1"
obj.author = "Thai Pangsakulyanont <dtinth@spacet.me>"
obj.homepage = "https://github.com/dtinth/FocusHighlight.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- FocusHighlight.windowFilter
--- Variable
--- Controls the window filter to use
obj.windowFilter = hs.window.filter.default

--- FocusHighlight.color
--- Variable
--- Controls the color in Hex format
obj.color = "#ffffff"

--- FocusHighlight.arrowSize
--- Variable
--- Controls the arrow size
obj.arrowSize = 256

local previousFrame = nil

function obj:start()
  self.windowFilter:subscribe(hs.window.filter.windowFocused, function(window, appName)
    local color = self.color
    local nextFrame = window:frame()

    -- Do not show the focus highlight if the window frame remains at the same position
    if previousFrame ~= nil and nextFrame.x == previousFrame.x and nextFrame.y == previousFrame.y and nextFrame.w == previousFrame.w and nextFrame.h == previousFrame.h then
      return
    end

    -- Draw an arrow if the frame moved significantly
    if previousFrame ~= nil then
      local arrowSize = self.arrowSize
      local arrowFrame = hs.geometry(previousFrame.x + previousFrame.w / 2 - arrowSize / 2, previousFrame.y + previousFrame.h / 2 - arrowSize / 2, arrowSize, arrowSize)
      local arrowFrameIntersection = arrowFrame:intersect(nextFrame)
      if arrowFrameIntersection.w * arrowFrameIntersection.h == 0 then
        local angle = math.atan2(
          (nextFrame.y + nextFrame.h / 2) - (previousFrame.y + previousFrame.h / 2),
          (nextFrame.x + nextFrame.w / 2) - (previousFrame.x + previousFrame.w / 2)
        ) * 180 / 3.1415

        hs.canvas.new(arrowFrame):appendElements(
          {
            action = "fill", type = "segments",
            fillColor = { alpha = 1.0, hex = color },
            coordinates = {
              { x = ".1", y = ".4" },
              { x = ".6", y = ".4" },
              { x = ".6", y = ".2" },
              { x = ".9", y = ".5" },
              { x = ".6", y = ".8" },
              { x = ".6", y = ".6" },
              { x = ".1", y = ".6" }
            },
            withShadow = true
          }
        ):rotateElement(1, angle):show():delete(1)
      end
    end

    previousFrame = nextFrame

    -- Draw a focus highlight
    hs.canvas.new(window:frame()):appendElements(
      {
        action = "fill", padding = 0, type = "rectangle",
        fillColor = { alpha = 0.1, hex = color },
      },
      {
        action = "stroke", padding = 4, type = "rectangle",
        strokeColor = { alpha = 1.0, hex = color },
        strokeWidth = 8,
        strokeJoinStyle = "round",
        withShadow = true,
      }
    ):show():delete(0.75)
  end)
end

return obj