local Creator = {}

function Creator.New(className: string, props: { [string]: any }?, children: { Instance }?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			if k ~= "Parent" then
				inst[k] = v
			end
		end
		if props.Parent then
			inst.Parent = props.Parent
		end
	end

	if children then
		for _, child in ipairs(children) do
			if typeof(child) == "Instance" then
				child.Parent = inst
			end
		end
	end

	return inst
end

function Creator.Round(parent: Instance, radius: number?): UICorner
	return Creator.New("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
		Parent = parent
	})
end

function Creator.Stroke(parent: Instance, color: Color3?, transparency: number?, thickness: number?): UIStroke
	return Creator.New("UIStroke", {
		Color = color or Color3.fromRGB(255, 255, 255),
		Transparency = transparency or 0.88,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent
	})
end

function Creator.Padding(parent: Instance, top: number, bottom: number, left: number, right: number): UIPadding
	return Creator.New("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
		PaddingRight = UDim.new(0, right),
		Parent = parent
	})
end

return Creator
