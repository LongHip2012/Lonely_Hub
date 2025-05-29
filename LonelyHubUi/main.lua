local NguyenMinhNhat = {
	Version = '1.1',
	EnableIcon = true,
};

local TweenSv = game:GetService('TweenService');
local UserInputSv = game:GetService('UserInputService');
local LocalPlayer = game:GetService('Players').LocalPlayer;
local CoreGui = (gethui and gethui()) or game:FindFirstChild('CoreGui') or LocalPlayer.PlayerGui;
local CurrentCamera = workspace.CurrentCamera;
local RunService = game:GetService('RunService');
local TextSv = game:GetService('TextService');

function NguyenMinhNhat:ChiuMyLy() : string
	return tostring(table.create(math.random(1,10),nil)):gsub('table: ','')
end;

function NguyenMinhNhat:Rounding(num, numDecimalPlaces) : number
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function NguyenMinhNhat:NewInput(frame : Frame) : TextButton
	local Bth = Instance.new('TextButton',frame);

	Bth.ZIndex = frame.ZIndex + 10;
	Bth.Size = UDim2.fromScale(1,1);
	Bth.BackgroundTransparency = 1;
	Bth.TextTransparency = 1;

	return Bth;
end;

------------------- BACKGROUND BLUR ---------------------
local function Fixed(planePos, planeNormal, rayOrigin, rayDirection)
	local n = planeNormal
	local d = rayDirection
	local v = rayOrigin - planePos

	local num = (n.x*v.x) + (n.y*v.y) + (n.z*v.z)
	local den = (n.x*d.x) + (n.y*d.y) + (n.z*d.z)
	local a = -num / den

	return rayOrigin + (a * rayDirection), a;
end;

function NguyenMinhNhat:SetBlur(frame,NoAutoBackground)
	local Part = Instance.new('Part',workspace.Camera);
	local DepthOfField = Instance.new('DepthOfFieldEffect',game:GetService('Lighting'));
	local SurfaceGui = Instance.new('SurfaceGui',Part);
	local BlockMesh = Instance.new("BlockMesh");

	BlockMesh.Parent = Part;

	Part.Material = Enum.Material.Glass;
	Part.Transparency = 1;
	Part.Reflectance = 1;
	Part.CastShadow = false;
	Part.Anchored = true;
	Part.CanCollide = false;
	Part.CanQuery = false;
	Part.CollisionGroup = NguyenMinhNhat:ChiuMyLy();
	Part.Size = Vector3.new(1, 1, 1) * 0.01;
	Part.Color = Color3.fromRGB(0,0,0);

	TweenSv:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
		Transparency = 0.8;
	}):Play()

	DepthOfField.Enabled = true;
	DepthOfField.FarIntensity = 1;
	DepthOfField.FocusDistance = 0;
	DepthOfField.InFocusRadius = 500;
	DepthOfField.NearIntensity = 1;

	SurfaceGui.AlwaysOnTop = true;
	SurfaceGui.Adornee = Part;
	SurfaceGui.Active = true;
	SurfaceGui.Face = Enum.NormalId.Front;
	SurfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;

	DepthOfField.Name = NguyenMinhNhat:ChiuMyLy();
	Part.Name = NguyenMinhNhat:ChiuMyLy();
	SurfaceGui.Name = NguyenMinhNhat:ChiuMyLy();

	local C4 = {
		Update = nil,
		Collection = SurfaceGui,
		Enabled = true,
		Instances = {
			BlockMesh = BlockMesh,
			Part = Part,
			DepthOfField = DepthOfField,
			SurfaceGui = SurfaceGui,
		},
		Signal = nil
	};

	local Update = function()
		local _,updatec = pcall(function()
			local userSettings = UserSettings():GetService("UserGameSettings")
			local qualityLevel = userSettings.SavedQualityLevel.Value

			if not NoAutoBackground then
				if qualityLevel < 8 then
					TweenSv:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
						Transparency = 1;
					}):Play()
				else
					TweenSv:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
						Transparency = 0.8;
					}):Play()
				end;
			end;
		end)

		local corner0 = frame.AbsolutePosition;
		local corner1 = corner0 + frame.AbsoluteSize;

		local ray0 = CurrentCamera.ScreenPointToRay(CurrentCamera,corner0.X, corner0.Y, 1);
		local ray1 = CurrentCamera.ScreenPointToRay(CurrentCamera,corner1.X, corner1.Y, 1);

		local planeOrigin = CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * (0.05 - CurrentCamera.NearPlaneZ);

		local planeNormal = CurrentCamera.CFrame.LookVector;

		local pos0 = Fixed(planeOrigin, planeNormal, ray0.Origin, ray0.Direction);
		local pos1 = Fixed(planeOrigin, planeNormal, ray1.Origin, ray1.Direction);

		pos0 = CurrentCamera.CFrame:PointToObjectSpace(pos0);
		pos1 = CurrentCamera.CFrame:PointToObjectSpace(pos1);

		local size   = pos1 - pos0;
		local center = (pos0 + pos1) / 2;

		BlockMesh.Offset = center
		BlockMesh.Scale  = size / 0.0101;
		Part.CFrame = CurrentCamera.CFrame;
	end

	C4.Update = Update;
	C4.Signal = RunService.RenderStepped:Connect(Update);

	pcall(function()
		C4.Signal2 = CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(function()
			Part.CFrame = CurrentCamera.CFrame;
		end);
	end)

	C4.Destroy = function()
		C4.Signal:Disconnect();
		C4.Signal2:Disconnect();
		C4.Update = function()

		end;

		TweenSv:Create(Part,TweenInfo.new(1),{
			Transparency = 1
		}):Play();

		DepthOfField:Destroy();
		Part:Destroy()
	end;

	return C4;
end;

NguyenMinhNhat.CreateEmuIcon = function(protect : ImageLabel, text : string)
	local label = Instance.new('TextLabel',protect)
	label.Text = text
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Size = UDim2.fromScale(1,1)
	label.RichText = true
	label.ZIndex = protect.ZIndex + 1
	label.TextColor3 = protect.ImageColor3
end;

NguyenMinhNhat.HookAssetId = function()
	if hookfunc or hookfunction then
		local hooking = hookfunc or hookfunction or function() end;
		local newCclosure = newcclosure or function() end;
		
		hooking(game:GetService('ContentProvider').PreloadAsync,function()
			return 1;
		end);
		
		hooking(game:GetService('ContentProvider').Preload,function()
			return 2;
		end);
	end;
end;

NguyenMinhNhat.Assets = { -- Icons
	["lucide-accessibility"] = "rbxassetid://10709751939",
	["lucide-activity"] = "rbxassetid://10709752035",
	["lucide-air-vent"] = "rbxassetid://10709752131",
	["lucide-airplay"] = "rbxassetid://10709752254",
	["lucide-alarm-check"] = "rbxassetid://10709752405",
	["lucide-alarm-clock"] = "rbxassetid://10709752630",
	["lucide-alarm-clock-off"] = "rbxassetid://10709752508",
	["lucide-alarm-minus"] = "rbxassetid://10709752732",
	["lucide-alarm-plus"] = "rbxassetid://10709752825",
	["lucide-album"] = "rbxassetid://10709752906",
	["lucide-alert-circle"] = "rbxassetid://10709752996",
	["lucide-alert-octagon"] = "rbxassetid://10709753064",
	["lucide-alert-triangle"] = "rbxassetid://10709753149",
	["lucide-align-center"] = "rbxassetid://10709753570",
	["lucide-align-center-horizontal"] = "rbxassetid://10709753272",
	["lucide-align-center-vertical"] = "rbxassetid://10709753421",
	["lucide-align-end-horizontal"] = "rbxassetid://10709753692",
	["lucide-align-end-vertical"] = "rbxassetid://10709753808",
	["lucide-align-horizontal-distribute-center"] = "rbxassetid://10747779791",
	["lucide-align-horizontal-distribute-end"] = "rbxassetid://10747784534",
	["lucide-align-horizontal-distribute-start"] = "rbxassetid://10709754118",
	["lucide-align-horizontal-justify-center"] = "rbxassetid://10709754204",
	["lucide-align-horizontal-justify-end"] = "rbxassetid://10709754317",
	["lucide-align-horizontal-justify-start"] = "rbxassetid://10709754436",
	["lucide-align-horizontal-space-around"] = "rbxassetid://10709754590",
	["lucide-align-horizontal-space-between"] = "rbxassetid://10709754749",
	["lucide-align-justify"] = "rbxassetid://10709759610",
	["lucide-align-left"] = "rbxassetid://10709759764",
	["lucide-align-right"] = "rbxassetid://10709759895",
	["lucide-align-start-horizontal"] = "rbxassetid://10709760051",
	["lucide-align-start-vertical"] = "rbxassetid://10709760244",
	["lucide-align-vertical-distribute-center"] = "rbxassetid://10709760351",
	["lucide-align-vertical-distribute-end"] = "rbxassetid://10709760434",
	["lucide-align-vertical-distribute-start"] = "rbxassetid://10709760612",
	["lucide-align-vertical-justify-center"] = "rbxassetid://10709760814",
	["lucide-align-vertical-justify-end"] = "rbxassetid://10709761003",
	["lucide-align-vertical-justify-start"] = "rbxassetid://10709761176",
	["lucide-align-vertical-space-around"] = "rbxassetid://10709761324",
	["lucide-align-vertical-space-between"] = "rbxassetid://10709761434",
	["lucide-anchor"] = "rbxassetid://10709761530",
	["lucide-angry"] = "rbxassetid://10709761629",
	["lucide-annoyed"] = "rbxassetid://10709761722",
	["lucide-aperture"] = "rbxassetid://10709761813",
	["lucide-apple"] = "rbxassetid://10709761889",
	["lucide-archive"] = "rbxassetid://10709762233",
	["lucide-archive-restore"] = "rbxassetid://10709762058",
	["lucide-armchair"] = "rbxassetid://10709762327",
	["lucide-arrow-big-down"] = "rbxassetid://10747796644",
	["lucide-arrow-big-left"] = "rbxassetid://10709762574",
	["lucide-arrow-big-right"] = "rbxassetid://10709762727",
	["lucide-arrow-big-up"] = "rbxassetid://10709762879",
	["lucide-arrow-down"] = "rbxassetid://10709767827",
	["lucide-arrow-down-circle"] = "rbxassetid://10709763034",
	["lucide-arrow-down-left"] = "rbxassetid://10709767656",
	["lucide-arrow-down-right"] = "rbxassetid://10709767750",
	["lucide-arrow-left"] = "rbxassetid://10709768114",
	["lucide-arrow-left-circle"] = "rbxassetid://10709767936",
	["lucide-arrow-left-right"] = "rbxassetid://10709768019",
	["lucide-arrow-right"] = "rbxassetid://10709768347",
	["lucide-arrow-right-circle"] = "rbxassetid://10709768226",
	["lucide-arrow-up"] = "rbxassetid://10709768939",
	["lucide-arrow-up-circle"] = "rbxassetid://10709768432",
	["lucide-arrow-up-down"] = "rbxassetid://10709768538",
	["lucide-arrow-up-left"] = "rbxassetid://10709768661",
	["lucide-arrow-up-right"] = "rbxassetid://10709768787",
	["lucide-asterisk"] = "rbxassetid://10709769095",
	["lucide-at-sign"] = "rbxassetid://10709769286",
	["lucide-award"] = "rbxassetid://10709769406",
	["lucide-axe"] = "rbxassetid://10709769508",
	["lucide-axis-3d"] = "rbxassetid://10709769598",
	["lucide-baby"] = "rbxassetid://10709769732",
	["lucide-backpack"] = "rbxassetid://10709769841",
	["lucide-baggage-claim"] = "rbxassetid://10709769935",
	["lucide-banana"] = "rbxassetid://10709770005",
	["lucide-banknote"] = "rbxassetid://10709770178",
	["lucide-bar-chart"] = "rbxassetid://10709773755",
	["lucide-bar-chart-2"] = "rbxassetid://10709770317",
	["lucide-bar-chart-3"] = "rbxassetid://10709770431",
	["lucide-bar-chart-4"] = "rbxassetid://10709770560",
	["lucide-bar-chart-horizontal"] = "rbxassetid://10709773669",
	["lucide-barcode"] = "rbxassetid://10747360675",
	["lucide-baseline"] = "rbxassetid://10709773863",
	["lucide-bath"] = "rbxassetid://10709773963",
	["lucide-battery"] = "rbxassetid://10709774640",
	["lucide-battery-charging"] = "rbxassetid://10709774068",
	["lucide-battery-full"] = "rbxassetid://10709774206",
	["lucide-battery-low"] = "rbxassetid://10709774370",
	["lucide-battery-medium"] = "rbxassetid://10709774513",
	["lucide-beaker"] = "rbxassetid://10709774756",
	["lucide-bed"] = "rbxassetid://10709775036",
	["lucide-bed-double"] = "rbxassetid://10709774864",
	["lucide-bed-single"] = "rbxassetid://10709774968",
	["lucide-beer"] = "rbxassetid://10709775167",
	["lucide-bell"] = "rbxassetid://10709775704",
	["lucide-bell-minus"] = "rbxassetid://10709775241",
	["lucide-bell-off"] = "rbxassetid://10709775320",
	["lucide-bell-plus"] = "rbxassetid://10709775448",
	["lucide-bell-ring"] = "rbxassetid://10709775560",
	["lucide-bike"] = "rbxassetid://10709775894",
	["lucide-binary"] = "rbxassetid://10709776050",
	["lucide-bitcoin"] = "rbxassetid://10709776126",
	["lucide-bluetooth"] = "rbxassetid://10709776655",
	["lucide-bluetooth-connected"] = "rbxassetid://10709776240",
	["lucide-bluetooth-off"] = "rbxassetid://10709776344",
	["lucide-bluetooth-searching"] = "rbxassetid://10709776501",
	["lucide-bold"] = "rbxassetid://10747813908",
	["lucide-bomb"] = "rbxassetid://10709781460",
	["lucide-bone"] = "rbxassetid://10709781605",
	["lucide-book"] = "rbxassetid://10709781824",
	["lucide-book-open"] = "rbxassetid://10709781717",
	["lucide-bookmark"] = "rbxassetid://10709782154",
	["lucide-bookmark-minus"] = "rbxassetid://10709781919",
	["lucide-bookmark-plus"] = "rbxassetid://10709782044",
	["lucide-bot"] = "rbxassetid://10709782230",
	["lucide-box"] = "rbxassetid://10709782497",
	["lucide-box-select"] = "rbxassetid://10709782342",
	["lucide-boxes"] = "rbxassetid://10709782582",
	["lucide-briefcase"] = "rbxassetid://10709782662",
	["lucide-brush"] = "rbxassetid://10709782758",
	["lucide-bug"] = "rbxassetid://10709782845",
	["lucide-building"] = "rbxassetid://10709783051",
	["lucide-building-2"] = "rbxassetid://10709782939",
	["lucide-bus"] = "rbxassetid://10709783137",
	["lucide-cake"] = "rbxassetid://10709783217",
	["lucide-calculator"] = "rbxassetid://10709783311",
	["lucide-calendar"] = "rbxassetid://10709789505",
	["lucide-calendar-check"] = "rbxassetid://10709783474",
	["lucide-calendar-check-2"] = "rbxassetid://10709783392",
	["lucide-calendar-clock"] = "rbxassetid://10709783577",
	["lucide-calendar-days"] = "rbxassetid://10709783673",
	["lucide-calendar-heart"] = "rbxassetid://10709783835",
	["lucide-calendar-minus"] = "rbxassetid://10709783959",
	["lucide-calendar-off"] = "rbxassetid://10709788784",
	["lucide-calendar-plus"] = "rbxassetid://10709788937",
	["lucide-calendar-range"] = "rbxassetid://10709789053",
	["lucide-calendar-search"] = "rbxassetid://10709789200",
	["lucide-calendar-x"] = "rbxassetid://10709789407",
	["lucide-calendar-x-2"] = "rbxassetid://10709789329",
	["lucide-camera"] = "rbxassetid://10709789686",
	["lucide-camera-off"] = "rbxassetid://10747822677",
	["lucide-car"] = "rbxassetid://10709789810",
	["lucide-carrot"] = "rbxassetid://10709789960",
	["lucide-cast"] = "rbxassetid://10709790097",
	["lucide-charge"] = "rbxassetid://10709790202",
	["lucide-check"] = "rbxassetid://10709790644",
	["lucide-check-circle"] = "rbxassetid://10709790387",
	["lucide-check-circle-2"] = "rbxassetid://10709790298",
	["lucide-check-square"] = "rbxassetid://10709790537",
	["lucide-chef-hat"] = "rbxassetid://10709790757",
	["lucide-cherry"] = "rbxassetid://10709790875",
	["lucide-chevron-down"] = "rbxassetid://10709790948",
	["lucide-chevron-first"] = "rbxassetid://10709791015",
	["lucide-chevron-last"] = "rbxassetid://10709791130",
	["lucide-chevron-left"] = "rbxassetid://10709791281",
	["lucide-chevron-right"] = "rbxassetid://10709791437",
	["lucide-chevron-up"] = "rbxassetid://10709791523",
	["lucide-chevrons-down"] = "rbxassetid://10709796864",
	["lucide-chevrons-down-up"] = "rbxassetid://10709791632",
	["lucide-chevrons-left"] = "rbxassetid://10709797151",
	["lucide-chevrons-left-right"] = "rbxassetid://10709797006",
	["lucide-chevrons-right"] = "rbxassetid://10709797382",
	["lucide-chevrons-right-left"] = "rbxassetid://10709797274",
	["lucide-chevrons-up"] = "rbxassetid://10709797622",
	["lucide-chevrons-up-down"] = "rbxassetid://10709797508",
	["lucide-chrome"] = "rbxassetid://10709797725",
	["lucide-circle"] = "rbxassetid://10709798174",
	["lucide-circle-dot"] = "rbxassetid://10709797837",
	["lucide-circle-ellipsis"] = "rbxassetid://10709797985",
	["lucide-circle-slashed"] = "rbxassetid://10709798100",
	["lucide-citrus"] = "rbxassetid://10709798276",
	["lucide-clapperboard"] = "rbxassetid://10709798350",
	["lucide-clipboard"] = "rbxassetid://10709799288",
	["lucide-clipboard-check"] = "rbxassetid://10709798443",
	["lucide-clipboard-copy"] = "rbxassetid://10709798574",
	["lucide-clipboard-edit"] = "rbxassetid://10709798682",
	["lucide-clipboard-list"] = "rbxassetid://10709798792",
	["lucide-clipboard-signature"] = "rbxassetid://10709798890",
	["lucide-clipboard-type"] = "rbxassetid://10709798999",
	["lucide-clipboard-x"] = "rbxassetid://10709799124",
	["lucide-clock"] = "rbxassetid://10709805144",
	["lucide-clock-1"] = "rbxassetid://10709799535",
	["lucide-clock-10"] = "rbxassetid://10709799718",
	["lucide-clock-11"] = "rbxassetid://10709799818",
	["lucide-clock-12"] = "rbxassetid://10709799962",
	["lucide-clock-2"] = "rbxassetid://10709803876",
	["lucide-clock-3"] = "rbxassetid://10709803989",
	["lucide-clock-4"] = "rbxassetid://10709804164",
	["lucide-clock-5"] = "rbxassetid://10709804291",
	["lucide-clock-6"] = "rbxassetid://10709804435",
	["lucide-clock-7"] = "rbxassetid://10709804599",
	["lucide-clock-8"] = "rbxassetid://10709804784",
	["lucide-clock-9"] = "rbxassetid://10709804996",
	["lucide-cloud"] = "rbxassetid://10709806740",
	["lucide-cloud-cog"] = "rbxassetid://10709805262",
	["lucide-cloud-drizzle"] = "rbxassetid://10709805371",
	["lucide-cloud-fog"] = "rbxassetid://10709805477",
	["lucide-cloud-hail"] = "rbxassetid://10709805596",
	["lucide-cloud-lightning"] = "rbxassetid://10709805727",
	["lucide-cloud-moon"] = "rbxassetid://10709805942",
	["lucide-cloud-moon-rain"] = "rbxassetid://10709805838",
	["lucide-cloud-off"] = "rbxassetid://10709806060",
	["lucide-cloud-rain"] = "rbxassetid://10709806277",
	["lucide-cloud-rain-wind"] = "rbxassetid://10709806166",
	["lucide-cloud-snow"] = "rbxassetid://10709806374",
	["lucide-cloud-sun"] = "rbxassetid://10709806631",
	["lucide-cloud-sun-rain"] = "rbxassetid://10709806475",
	["lucide-cloudy"] = "rbxassetid://10709806859",
	["lucide-clover"] = "rbxassetid://10709806995",
	["lucide-code"] = "rbxassetid://10709810463",
	["lucide-code-2"] = "rbxassetid://10709807111",
	["lucide-codepen"] = "rbxassetid://10709810534",
	["lucide-codesandbox"] = "rbxassetid://10709810676",
	["lucide-coffee"] = "rbxassetid://10709810814",
	["lucide-cog"] = "rbxassetid://10709810948",
	["lucide-coins"] = "rbxassetid://10709811110",
	["lucide-columns"] = "rbxassetid://10709811261",
	["lucide-command"] = "rbxassetid://10709811365",
	["lucide-compass"] = "rbxassetid://10709811445",
	["lucide-component"] = "rbxassetid://10709811595",
	["lucide-concierge-bell"] = "rbxassetid://10709811706",
	["lucide-connection"] = "rbxassetid://10747361219",
	["lucide-contact"] = "rbxassetid://10709811834",
	["lucide-contrast"] = "rbxassetid://10709811939",
	["lucide-cookie"] = "rbxassetid://10709812067",
	["lucide-copy"] = "rbxassetid://10709812159",
	["lucide-copyleft"] = "rbxassetid://10709812251",
	["lucide-copyright"] = "rbxassetid://10709812311",
	["lucide-corner-down-left"] = "rbxassetid://10709812396",
	["lucide-corner-down-right"] = "rbxassetid://10709812485",
	["lucide-corner-left-down"] = "rbxassetid://10709812632",
	["lucide-corner-left-up"] = "rbxassetid://10709812784",
	["lucide-corner-right-down"] = "rbxassetid://10709812939",
	["lucide-corner-right-up"] = "rbxassetid://10709813094",
	["lucide-corner-up-left"] = "rbxassetid://10709813185",
	["lucide-corner-up-right"] = "rbxassetid://10709813281",
	["lucide-cpu"] = "rbxassetid://10709813383",
	["lucide-croissant"] = "rbxassetid://10709818125",
	["lucide-crop"] = "rbxassetid://10709818245",
	["lucide-cross"] = "rbxassetid://10709818399",
	["lucide-crosshair"] = "rbxassetid://10709818534",
	["lucide-crown"] = "rbxassetid://10709818626",
	["lucide-cup-soda"] = "rbxassetid://10709818763",
	["lucide-curly-braces"] = "rbxassetid://10709818847",
	["lucide-currency"] = "rbxassetid://10709818931",
	["lucide-database"] = "rbxassetid://10709818996",
	["lucide-delete"] = "rbxassetid://10709819059",
	["lucide-diamond"] = "rbxassetid://10709819149",
	["lucide-dice-1"] = "rbxassetid://10709819266",
	["lucide-dice-2"] = "rbxassetid://10709819361",
	["lucide-dice-3"] = "rbxassetid://10709819508",
	["lucide-dice-4"] = "rbxassetid://10709819670",
	["lucide-dice-5"] = "rbxassetid://10709819801",
	["lucide-dice-6"] = "rbxassetid://10709819896",
	["lucide-dices"] = "rbxassetid://10723343321",
	["lucide-diff"] = "rbxassetid://10723343416",
	["lucide-disc"] = "rbxassetid://10723343537",
	["lucide-divide"] = "rbxassetid://10723343805",
	["lucide-divide-circle"] = "rbxassetid://10723343636",
	["lucide-divide-square"] = "rbxassetid://10723343737",
	["lucide-dollar-sign"] = "rbxassetid://10723343958",
	["lucide-download"] = "rbxassetid://10723344270",
	["lucide-download-cloud"] = "rbxassetid://10723344088",
	["lucide-droplet"] = "rbxassetid://10723344432",
	["lucide-droplets"] = "rbxassetid://10734883356",
	["lucide-drumstick"] = "rbxassetid://10723344737",
	["lucide-edit"] = "rbxassetid://10734883598",
	["lucide-edit-2"] = "rbxassetid://10723344885",
	["lucide-edit-3"] = "rbxassetid://10723345088",
	["lucide-egg"] = "rbxassetid://10723345518",
	["lucide-egg-fried"] = "rbxassetid://10723345347",
	["lucide-electricity"] = "rbxassetid://10723345749",
	["lucide-electricity-off"] = "rbxassetid://10723345643",
	["lucide-equal"] = "rbxassetid://10723345990",
	["lucide-equal-not"] = "rbxassetid://10723345866",
	["lucide-eraser"] = "rbxassetid://10723346158",
	["lucide-euro"] = "rbxassetid://10723346372",
	["lucide-expand"] = "rbxassetid://10723346553",
	["lucide-external-link"] = "rbxassetid://10723346684",
	["lucide-eye"] = "rbxassetid://10723346959",
	["lucide-eye-off"] = "rbxassetid://10723346871",
	["lucide-factory"] = "rbxassetid://10723347051",
	["lucide-fan"] = "rbxassetid://10723354359",
	["lucide-fast-forward"] = "rbxassetid://10723354521",
	["lucide-feather"] = "rbxassetid://10723354671",
	["lucide-figma"] = "rbxassetid://10723354801",
	["lucide-file"] = "rbxassetid://10723374641",
	["lucide-file-archive"] = "rbxassetid://10723354921",
	["lucide-file-audio"] = "rbxassetid://10723355148",
	["lucide-file-audio-2"] = "rbxassetid://10723355026",
	["lucide-file-axis-3d"] = "rbxassetid://10723355272",
	["lucide-file-badge"] = "rbxassetid://10723355622",
	["lucide-file-badge-2"] = "rbxassetid://10723355451",
	["lucide-file-bar-chart"] = "rbxassetid://10723355887",
	["lucide-file-bar-chart-2"] = "rbxassetid://10723355746",
	["lucide-file-box"] = "rbxassetid://10723355989",
	["lucide-file-check"] = "rbxassetid://10723356210",
	["lucide-file-check-2"] = "rbxassetid://10723356100",
	["lucide-file-clock"] = "rbxassetid://10723356329",
	["lucide-file-code"] = "rbxassetid://10723356507",
	["lucide-file-cog"] = "rbxassetid://10723356830",
	["lucide-file-cog-2"] = "rbxassetid://10723356676",
	["lucide-file-diff"] = "rbxassetid://10723357039",
	["lucide-file-digit"] = "rbxassetid://10723357151",
	["lucide-file-down"] = "rbxassetid://10723357322",
	["lucide-file-edit"] = "rbxassetid://10723357495",
	["lucide-file-heart"] = "rbxassetid://10723357637",
	["lucide-file-image"] = "rbxassetid://10723357790",
	["lucide-file-input"] = "rbxassetid://10723357933",
	["lucide-file-json"] = "rbxassetid://10723364435",
	["lucide-file-json-2"] = "rbxassetid://10723364361",
	["lucide-file-key"] = "rbxassetid://10723364605",
	["lucide-file-key-2"] = "rbxassetid://10723364515",
	["lucide-file-line-chart"] = "rbxassetid://10723364725",
	["lucide-file-lock"] = "rbxassetid://10723364957",
	["lucide-file-lock-2"] = "rbxassetid://10723364861",
	["lucide-file-minus"] = "rbxassetid://10723365254",
	["lucide-file-minus-2"] = "rbxassetid://10723365086",
	["lucide-file-output"] = "rbxassetid://10723365457",
	["lucide-file-pie-chart"] = "rbxassetid://10723365598",
	["lucide-file-plus"] = "rbxassetid://10723365877",
	["lucide-file-plus-2"] = "rbxassetid://10723365766",
	["lucide-file-question"] = "rbxassetid://10723365987",
	["lucide-file-scan"] = "rbxassetid://10723366167",
	["lucide-file-search"] = "rbxassetid://10723366550",
	["lucide-file-search-2"] = "rbxassetid://10723366340",
	["lucide-file-signature"] = "rbxassetid://10723366741",
	["lucide-file-spreadsheet"] = "rbxassetid://10723366962",
	["lucide-file-symlink"] = "rbxassetid://10723367098",
	["lucide-file-terminal"] = "rbxassetid://10723367244",
	["lucide-file-text"] = "rbxassetid://10723367380",
	["lucide-file-type"] = "rbxassetid://10723367606",
	["lucide-file-type-2"] = "rbxassetid://10723367509",
	["lucide-file-up"] = "rbxassetid://10723367734",
	["lucide-file-video"] = "rbxassetid://10723373884",
	["lucide-file-video-2"] = "rbxassetid://10723367834",
	["lucide-file-volume"] = "rbxassetid://10723374172",
	["lucide-file-volume-2"] = "rbxassetid://10723374030",
	["lucide-file-warning"] = "rbxassetid://10723374276",
	["lucide-file-x"] = "rbxassetid://10723374544",
	["lucide-file-x-2"] = "rbxassetid://10723374378",
	["lucide-files"] = "rbxassetid://10723374759",
	["lucide-film"] = "rbxassetid://10723374981",
	["lucide-filter"] = "rbxassetid://10723375128",
	["lucide-fingerprint"] = "rbxassetid://10723375250",
	["lucide-flag"] = "rbxassetid://10723375890",
	["lucide-flag-off"] = "rbxassetid://10723375443",
	["lucide-flag-triangle-left"] = "rbxassetid://10723375608",
	["lucide-flag-triangle-right"] = "rbxassetid://10723375727",
	["lucide-flame"] = "rbxassetid://10723376114",
	["lucide-flashlight"] = "rbxassetid://10723376471",
	["lucide-flashlight-off"] = "rbxassetid://10723376365",
	["lucide-flask-conical"] = "rbxassetid://10734883986",
	["lucide-flask-round"] = "rbxassetid://10723376614",
	["lucide-flip-horizontal"] = "rbxassetid://10723376884",
	["lucide-flip-horizontal-2"] = "rbxassetid://10723376745",
	["lucide-flip-vertical"] = "rbxassetid://10723377138",
	["lucide-flip-vertical-2"] = "rbxassetid://10723377026",
	["lucide-flower"] = "rbxassetid://10747830374",
	["lucide-flower-2"] = "rbxassetid://10723377305",
	["lucide-focus"] = "rbxassetid://10723377537",
	["lucide-folder"] = "rbxassetid://10723387563",
	["lucide-folder-archive"] = "rbxassetid://10723384478",
	["lucide-folder-check"] = "rbxassetid://10723384605",
	["lucide-folder-clock"] = "rbxassetid://10723384731",
	["lucide-folder-closed"] = "rbxassetid://10723384893",
	["lucide-folder-cog"] = "rbxassetid://10723385213",
	["lucide-folder-cog-2"] = "rbxassetid://10723385036",
	["lucide-folder-down"] = "rbxassetid://10723385338",
	["lucide-folder-edit"] = "rbxassetid://10723385445",
	["lucide-folder-heart"] = "rbxassetid://10723385545",
	["lucide-folder-input"] = "rbxassetid://10723385721",
	["lucide-folder-key"] = "rbxassetid://10723385848",
	["lucide-folder-lock"] = "rbxassetid://10723386005",
	["lucide-folder-minus"] = "rbxassetid://10723386127",
	["lucide-folder-open"] = "rbxassetid://10723386277",
	["lucide-folder-output"] = "rbxassetid://10723386386",
	["lucide-folder-plus"] = "rbxassetid://10723386531",
	["lucide-folder-search"] = "rbxassetid://10723386787",
	["lucide-folder-search-2"] = "rbxassetid://10723386674",
	["lucide-folder-symlink"] = "rbxassetid://10723386930",
	["lucide-folder-tree"] = "rbxassetid://10723387085",
	["lucide-folder-up"] = "rbxassetid://10723387265",
	["lucide-folder-x"] = "rbxassetid://10723387448",
	["lucide-folders"] = "rbxassetid://10723387721",
	["lucide-form-input"] = "rbxassetid://10723387841",
	["lucide-forward"] = "rbxassetid://10723388016",
	["lucide-frame"] = "rbxassetid://10723394389",
	["lucide-framer"] = "rbxassetid://10723394565",
	["lucide-frown"] = "rbxassetid://10723394681",
	["lucide-fuel"] = "rbxassetid://10723394846",
	["lucide-function-square"] = "rbxassetid://10723395041",
	["lucide-gamepad"] = "rbxassetid://10723395457",
	["lucide-gamepad-2"] = "rbxassetid://10723395215",
	["lucide-gauge"] = "rbxassetid://10723395708",
	["lucide-gavel"] = "rbxassetid://10723395896",
	["lucide-gem"] = "rbxassetid://10723396000",
	["lucide-ghost"] = "rbxassetid://10723396107",
	["lucide-gift"] = "rbxassetid://10723396402",
	["lucide-gift-card"] = "rbxassetid://10723396225",
	["lucide-git-branch"] = "rbxassetid://10723396676",
	["lucide-git-branch-plus"] = "rbxassetid://10723396542",
	["lucide-git-commit"] = "rbxassetid://10723396812",
	["lucide-git-compare"] = "rbxassetid://10723396954",
	["lucide-git-fork"] = "rbxassetid://10723397049",
	["lucide-git-merge"] = "rbxassetid://10723397165",
	["lucide-git-pull-request"] = "rbxassetid://10723397431",
	["lucide-git-pull-request-closed"] = "rbxassetid://10723397268",
	["lucide-git-pull-request-draft"] = "rbxassetid://10734884302",
	["lucide-glass"] = "rbxassetid://10723397788",
	["lucide-glass-2"] = "rbxassetid://10723397529",
	["lucide-glass-water"] = "rbxassetid://10723397678",
	["lucide-glasses"] = "rbxassetid://10723397895",
	["lucide-globe"] = "rbxassetid://10723404337",
	["lucide-globe-2"] = "rbxassetid://10723398002",
	["lucide-grab"] = "rbxassetid://10723404472",
	["lucide-graduation-cap"] = "rbxassetid://10723404691",
	["lucide-grape"] = "rbxassetid://10723404822",
	["lucide-grid"] = "rbxassetid://10723404936",
	["lucide-grip-horizontal"] = "rbxassetid://10723405089",
	["lucide-grip-vertical"] = "rbxassetid://10723405236",
	["lucide-hammer"] = "rbxassetid://10723405360",
	["lucide-hand"] = "rbxassetid://10723405649",
	["lucide-hand-metal"] = "rbxassetid://10723405508",
	["lucide-hard-drive"] = "rbxassetid://10723405749",
	["lucide-hard-hat"] = "rbxassetid://10723405859",
	["lucide-hash"] = "rbxassetid://10723405975",
	["lucide-haze"] = "rbxassetid://10723406078",
	["lucide-headphones"] = "rbxassetid://10723406165",
	["lucide-heart"] = "rbxassetid://10723406885",
	["lucide-heart-crack"] = "rbxassetid://10723406299",
	["lucide-heart-handshake"] = "rbxassetid://10723406480",
	["lucide-heart-off"] = "rbxassetid://10723406662",
	["lucide-heart-pulse"] = "rbxassetid://10723406795",
	["lucide-help-circle"] = "rbxassetid://10723406988",
	["lucide-hexagon"] = "rbxassetid://10723407092",
	["lucide-highlighter"] = "rbxassetid://10723407192",
	["lucide-history"] = "rbxassetid://10723407335",
	["lucide-home"] = "rbxassetid://10723407389",
	["lucide-hourglass"] = "rbxassetid://10723407498",
	["lucide-ice-cream"] = "rbxassetid://10723414308",
	["lucide-image"] = "rbxassetid://10723415040",
	["lucide-image-minus"] = "rbxassetid://10723414487",
	["lucide-image-off"] = "rbxassetid://10723414677",
	["lucide-image-plus"] = "rbxassetid://10723414827",
	["lucide-import"] = "rbxassetid://10723415205",
	["lucide-inbox"] = "rbxassetid://10723415335",
	["lucide-indent"] = "rbxassetid://10723415494",
	["lucide-indian-rupee"] = "rbxassetid://10723415642",
	["lucide-infinity"] = "rbxassetid://10723415766",
	["lucide-info"] = "rbxassetid://10723415903",
	["lucide-inspect"] = "rbxassetid://10723416057",
	["lucide-italic"] = "rbxassetid://10723416195",
	["lucide-japanese-yen"] = "rbxassetid://10723416363",
	["lucide-joystick"] = "rbxassetid://10723416527",
	["lucide-key"] = "rbxassetid://10723416652",
	["lucide-keyboard"] = "rbxassetid://10723416765",
	["lucide-lamp"] = "rbxassetid://10723417513",
	["lucide-lamp-ceiling"] = "rbxassetid://10723416922",
	["lucide-lamp-desk"] = "rbxassetid://10723417016",
	["lucide-lamp-floor"] = "rbxassetid://10723417131",
	["lucide-lamp-wall-down"] = "rbxassetid://10723417240",
	["lucide-lamp-wall-up"] = "rbxassetid://10723417356",
	["lucide-landmark"] = "rbxassetid://10723417608",
	["lucide-languages"] = "rbxassetid://10723417703",
	["lucide-laptop"] = "rbxassetid://10723423881",
	["lucide-laptop-2"] = "rbxassetid://10723417797",
	["lucide-lasso"] = "rbxassetid://10723424235",
	["lucide-lasso-select"] = "rbxassetid://10723424058",
	["lucide-laugh"] = "rbxassetid://10723424372",
	["lucide-layers"] = "rbxassetid://10723424505",
	["lucide-layout"] = "rbxassetid://10723425376",
	["lucide-layout-dashboard"] = "rbxassetid://10723424646",
	["lucide-layout-grid"] = "rbxassetid://10723424838",
	["lucide-layout-list"] = "rbxassetid://10723424963",
	["lucide-layout-template"] = "rbxassetid://10723425187",
	["lucide-leaf"] = "rbxassetid://10723425539",
	["lucide-library"] = "rbxassetid://10723425615",
	["lucide-life-buoy"] = "rbxassetid://10723425685",
	["lucide-lightbulb"] = "rbxassetid://10723425852",
	["lucide-lightbulb-off"] = "rbxassetid://10723425762",
	["lucide-line-chart"] = "rbxassetid://10723426393",
	["lucide-link"] = "rbxassetid://10723426722",
	["lucide-link-2"] = "rbxassetid://10723426595",
	["lucide-link-2-off"] = "rbxassetid://10723426513",
	["lucide-list"] = "rbxassetid://10723433811",
	["lucide-list-checks"] = "rbxassetid://10734884548",
	["lucide-list-end"] = "rbxassetid://10723426886",
	["lucide-list-minus"] = "rbxassetid://10723426986",
	["lucide-list-music"] = "rbxassetid://10723427081",
	["lucide-list-ordered"] = "rbxassetid://10723427199",
	["lucide-list-plus"] = "rbxassetid://10723427334",
	["lucide-list-start"] = "rbxassetid://10723427494",
	["lucide-list-video"] = "rbxassetid://10723427619",
	["lucide-list-x"] = "rbxassetid://10723433655",
	["lucide-loader"] = "rbxassetid://10723434070",
	["lucide-loader-2"] = "rbxassetid://10723433935",
	["lucide-locate"] = "rbxassetid://10723434557",
	["lucide-locate-fixed"] = "rbxassetid://10723434236",
	["lucide-locate-off"] = "rbxassetid://10723434379",
	["lucide-lock"] = "rbxassetid://10723434711",
	["lucide-log-in"] = "rbxassetid://10723434830",
	["lucide-log-out"] = "rbxassetid://10723434906",
	["lucide-luggage"] = "rbxassetid://10723434993",
	["lucide-magnet"] = "rbxassetid://10723435069",
	["lucide-mail"] = "rbxassetid://10734885430",
	["lucide-mail-check"] = "rbxassetid://10723435182",
	["lucide-mail-minus"] = "rbxassetid://10723435261",
	["lucide-mail-open"] = "rbxassetid://10723435342",
	["lucide-mail-plus"] = "rbxassetid://10723435443",
	["lucide-mail-question"] = "rbxassetid://10723435515",
	["lucide-mail-search"] = "rbxassetid://10734884739",
	["lucide-mail-warning"] = "rbxassetid://10734885015",
	["lucide-mail-x"] = "rbxassetid://10734885247",
	["lucide-mails"] = "rbxassetid://10734885614",
	["lucide-map"] = "rbxassetid://10734886202",
	["lucide-map-pin"] = "rbxassetid://10734886004",
	["lucide-map-pin-off"] = "rbxassetid://10734885803",
	["lucide-maximize"] = "rbxassetid://10734886735",
	["lucide-maximize-2"] = "rbxassetid://10734886496",
	["lucide-medal"] = "rbxassetid://10734887072",
	["lucide-megaphone"] = "rbxassetid://10734887454",
	["lucide-megaphone-off"] = "rbxassetid://10734887311",
	["lucide-meh"] = "rbxassetid://10734887603",
	["lucide-menu"] = "rbxassetid://10734887784",
	["lucide-message-circle"] = "rbxassetid://10734888000",
	["lucide-message-square"] = "rbxassetid://10734888228",
	["lucide-mic"] = "rbxassetid://10734888864",
	["lucide-mic-2"] = "rbxassetid://10734888430",
	["lucide-mic-off"] = "rbxassetid://10734888646",
	["lucide-microscope"] = "rbxassetid://10734889106",
	["lucide-microwave"] = "rbxassetid://10734895076",
	["lucide-milestone"] = "rbxassetid://10734895310",
	["lucide-minimize"] = "rbxassetid://10734895698",
	["lucide-minimize-2"] = "rbxassetid://10734895530",
	["lucide-minus"] = "rbxassetid://10734896206",
	["lucide-minus-circle"] = "rbxassetid://10734895856",
	["lucide-minus-square"] = "rbxassetid://10734896029",
	["lucide-monitor"] = "rbxassetid://10734896881",
	["lucide-monitor-off"] = "rbxassetid://10734896360",
	["lucide-monitor-speaker"] = "rbxassetid://10734896512",
	["lucide-moon"] = "rbxassetid://10734897102",
	["lucide-more-horizontal"] = "rbxassetid://10734897250",
	["lucide-more-vertical"] = "rbxassetid://10734897387",
	["lucide-mountain"] = "rbxassetid://10734897956",
	["lucide-mountain-snow"] = "rbxassetid://10734897665",
	["lucide-mouse"] = "rbxassetid://10734898592",
	["lucide-mouse-pointer"] = "rbxassetid://10734898476",
	["lucide-mouse-pointer-2"] = "rbxassetid://10734898194",
	["lucide-mouse-pointer-click"] = "rbxassetid://10734898355",
	["lucide-move"] = "rbxassetid://10734900011",
	["lucide-move-3d"] = "rbxassetid://10734898756",
	["lucide-move-diagonal"] = "rbxassetid://10734899164",
	["lucide-move-diagonal-2"] = "rbxassetid://10734898934",
	["lucide-move-horizontal"] = "rbxassetid://10734899414",
	["lucide-move-vertical"] = "rbxassetid://10734899821",
	["lucide-music"] = "rbxassetid://10734905958",
	["lucide-music-2"] = "rbxassetid://10734900215",
	["lucide-music-3"] = "rbxassetid://10734905665",
	["lucide-music-4"] = "rbxassetid://10734905823",
	["lucide-navigation"] = "rbxassetid://10734906744",
	["lucide-navigation-2"] = "rbxassetid://10734906332",
	["lucide-navigation-2-off"] = "rbxassetid://10734906144",
	["lucide-navigation-off"] = "rbxassetid://10734906580",
	["lucide-network"] = "rbxassetid://10734906975",
	["lucide-newspaper"] = "rbxassetid://10734907168",
	["lucide-octagon"] = "rbxassetid://10734907361",
	["lucide-option"] = "rbxassetid://10734907649",
	["lucide-outdent"] = "rbxassetid://10734907933",
	["lucide-package"] = "rbxassetid://10734909540",
	["lucide-package-2"] = "rbxassetid://10734908151",
	["lucide-package-check"] = "rbxassetid://10734908384",
	["lucide-package-minus"] = "rbxassetid://10734908626",
	["lucide-package-open"] = "rbxassetid://10734908793",
	["lucide-package-plus"] = "rbxassetid://10734909016",
	["lucide-package-search"] = "rbxassetid://10734909196",
	["lucide-package-x"] = "rbxassetid://10734909375",
	["lucide-paint-bucket"] = "rbxassetid://10734909847",
	["lucide-paintbrush"] = "rbxassetid://10734910187",
	["lucide-paintbrush-2"] = "rbxassetid://10734910030",
	["lucide-palette"] = "rbxassetid://10734910430",
	["lucide-palmtree"] = "rbxassetid://10734910680",
	["lucide-paperclip"] = "rbxassetid://10734910927",
	["lucide-party-popper"] = "rbxassetid://10734918735",
	["lucide-pause"] = "rbxassetid://10734919336",
	["lucide-pause-circle"] = "rbxassetid://10735024209",
	["lucide-pause-octagon"] = "rbxassetid://10734919143",
	["lucide-pen-tool"] = "rbxassetid://10734919503",
	["lucide-pencil"] = "rbxassetid://10734919691",
	["lucide-percent"] = "rbxassetid://10734919919",
	["lucide-person-standing"] = "rbxassetid://10734920149",
	["lucide-phone"] = "rbxassetid://10734921524",
	["lucide-phone-call"] = "rbxassetid://10734920305",
	["lucide-phone-forwarded"] = "rbxassetid://10734920508",
	["lucide-phone-incoming"] = "rbxassetid://10734920694",
	["lucide-phone-missed"] = "rbxassetid://10734920845",
	["lucide-phone-off"] = "rbxassetid://10734921077",
	["lucide-phone-outgoing"] = "rbxassetid://10734921288",
	["lucide-pie-chart"] = "rbxassetid://10734921727",
	["lucide-piggy-bank"] = "rbxassetid://10734921935",
	["lucide-pin"] = "rbxassetid://10734922324",
	["lucide-pin-off"] = "rbxassetid://10734922180",
	["lucide-pipette"] = "rbxassetid://10734922497",
	["lucide-pizza"] = "rbxassetid://10734922774",
	["lucide-plane"] = "rbxassetid://10734922971",
	["lucide-play"] = "rbxassetid://10734923549",
	["lucide-play-circle"] = "rbxassetid://10734923214",
	["lucide-plus"] = "rbxassetid://10734924532",
	["lucide-plus-circle"] = "rbxassetid://10734923868",
	["lucide-plus-square"] = "rbxassetid://10734924219",
	["lucide-podcast"] = "rbxassetid://10734929553",
	["lucide-pointer"] = "rbxassetid://10734929723",
	["lucide-pound-sterling"] = "rbxassetid://10734929981",
	["lucide-power"] = "rbxassetid://10734930466",
	["lucide-power-off"] = "rbxassetid://10734930257",
	["lucide-printer"] = "rbxassetid://10734930632",
	["lucide-puzzle"] = "rbxassetid://10734930886",
	["lucide-quote"] = "rbxassetid://10734931234",
	["lucide-radio"] = "rbxassetid://10734931596",
	["lucide-radio-receiver"] = "rbxassetid://10734931402",
	["lucide-rectangle-horizontal"] = "rbxassetid://10734931777",
	["lucide-rectangle-vertical"] = "rbxassetid://10734932081",
	["lucide-recycle"] = "rbxassetid://10734932295",
	["lucide-redo"] = "rbxassetid://10734932822",
	["lucide-redo-2"] = "rbxassetid://10734932586",
	["lucide-refresh-ccw"] = "rbxassetid://10734933056",
	["lucide-refresh-cw"] = "rbxassetid://10734933222",
	["lucide-refrigerator"] = "rbxassetid://10734933465",
	["lucide-regex"] = "rbxassetid://10734933655",
	["lucide-repeat"] = "rbxassetid://10734933966",
	["lucide-repeat-1"] = "rbxassetid://10734933826",
	["lucide-reply"] = "rbxassetid://10734934252",
	["lucide-reply-all"] = "rbxassetid://10734934132",
	["lucide-rewind"] = "rbxassetid://10734934347",
	["lucide-rocket"] = "rbxassetid://10734934585",
	["lucide-rocking-chair"] = "rbxassetid://10734939942",
	["lucide-rotate-3d"] = "rbxassetid://10734940107",
	["lucide-rotate-ccw"] = "rbxassetid://10734940376",
	["lucide-rotate-cw"] = "rbxassetid://10734940654",
	["lucide-rss"] = "rbxassetid://10734940825",
	["lucide-ruler"] = "rbxassetid://10734941018",
	["lucide-russian-ruble"] = "rbxassetid://10734941199",
	["lucide-sailboat"] = "rbxassetid://10734941354",
	["lucide-save"] = "rbxassetid://10734941499",
	["lucide-scale"] = "rbxassetid://10734941912",
	["lucide-scale-3d"] = "rbxassetid://10734941739",
	["lucide-scaling"] = "rbxassetid://10734942072",
	["lucide-scan"] = "rbxassetid://10734942565",
	["lucide-scan-face"] = "rbxassetid://10734942198",
	["lucide-scan-line"] = "rbxassetid://10734942351",
	["lucide-scissors"] = "rbxassetid://10734942778",
	["lucide-screen-share"] = "rbxassetid://10734943193",
	["lucide-screen-share-off"] = "rbxassetid://10734942967",
	["lucide-scroll"] = "rbxassetid://10734943448",
	["lucide-search"] = "rbxassetid://10734943674",
	["lucide-send"] = "rbxassetid://10734943902",
	["lucide-separator-horizontal"] = "rbxassetid://10734944115",
	["lucide-separator-vertical"] = "rbxassetid://10734944326",
	["lucide-server"] = "rbxassetid://10734949856",
	["lucide-server-cog"] = "rbxassetid://10734944444",
	["lucide-server-crash"] = "rbxassetid://10734944554",
	["lucide-server-off"] = "rbxassetid://10734944668",
	["lucide-settings"] = "rbxassetid://10734950309",
	["lucide-settings-2"] = "rbxassetid://10734950020",
	["lucide-share"] = "rbxassetid://10734950813",
	["lucide-share-2"] = "rbxassetid://10734950553",
	["lucide-sheet"] = "rbxassetid://10734951038",
	["lucide-shield"] = "rbxassetid://10734951847",
	["lucide-shield-alert"] = "rbxassetid://10734951173",
	["lucide-shield-check"] = "rbxassetid://10734951367",
	["lucide-shield-close"] = "rbxassetid://10734951535",
	["lucide-shield-off"] = "rbxassetid://10734951684",
	["lucide-shirt"] = "rbxassetid://10734952036",
	["lucide-shopping-bag"] = "rbxassetid://10734952273",
	["lucide-shopping-cart"] = "rbxassetid://10734952479",
	["lucide-shovel"] = "rbxassetid://10734952773",
	["lucide-shower-head"] = "rbxassetid://10734952942",
	["lucide-shrink"] = "rbxassetid://10734953073",
	["lucide-shrub"] = "rbxassetid://10734953241",
	["lucide-shuffle"] = "rbxassetid://10734953451",
	["lucide-sidebar"] = "rbxassetid://10734954301",
	["lucide-sidebar-close"] = "rbxassetid://10734953715",
	["lucide-sidebar-open"] = "rbxassetid://10734954000",
	["lucide-sigma"] = "rbxassetid://10734954538",
	["lucide-signal"] = "rbxassetid://10734961133",
	["lucide-signal-high"] = "rbxassetid://10734954807",
	["lucide-signal-low"] = "rbxassetid://10734955080",
	["lucide-signal-medium"] = "rbxassetid://10734955336",
	["lucide-signal-zero"] = "rbxassetid://10734960878",
	["lucide-siren"] = "rbxassetid://10734961284",
	["lucide-skip-back"] = "rbxassetid://10734961526",
	["lucide-skip-forward"] = "rbxassetid://10734961809",
	["lucide-skull"] = "rbxassetid://10734962068",
	["lucide-slack"] = "rbxassetid://10734962339",
	["lucide-slash"] = "rbxassetid://10734962600",
	["lucide-slice"] = "rbxassetid://10734963024",
	["lucide-sliders"] = "rbxassetid://10734963400",
	["lucide-sliders-horizontal"] = "rbxassetid://10734963191",
	["lucide-smartphone"] = "rbxassetid://10734963940",
	["lucide-smartphone-charging"] = "rbxassetid://10734963671",
	["lucide-smile"] = "rbxassetid://10734964441",
	["lucide-smile-plus"] = "rbxassetid://10734964188",
	["lucide-snowflake"] = "rbxassetid://10734964600",
	["lucide-sofa"] = "rbxassetid://10734964852",
	["lucide-sort-asc"] = "rbxassetid://10734965115",
	["lucide-sort-desc"] = "rbxassetid://10734965287",
	["lucide-speaker"] = "rbxassetid://10734965419",
	["lucide-sprout"] = "rbxassetid://10734965572",
	["lucide-square"] = "rbxassetid://10734965702",
	["lucide-star"] = "rbxassetid://10734966248",
	["lucide-star-half"] = "rbxassetid://10734965897",
	["lucide-star-off"] = "rbxassetid://10734966097",
	["lucide-stethoscope"] = "rbxassetid://10734966384",
	["lucide-sticker"] = "rbxassetid://10734972234",
	["lucide-sticky-note"] = "rbxassetid://10734972463",
	["lucide-stop-circle"] = "rbxassetid://10734972621",
	["lucide-stretch-horizontal"] = "rbxassetid://10734972862",
	["lucide-stretch-vertical"] = "rbxassetid://10734973130",
	["lucide-strikethrough"] = "rbxassetid://10734973290",
	["lucide-subscript"] = "rbxassetid://10734973457",
	["lucide-sun"] = "rbxassetid://10734974297",
	["lucide-sun-dim"] = "rbxassetid://10734973645",
	["lucide-sun-medium"] = "rbxassetid://10734973778",
	["lucide-sun-moon"] = "rbxassetid://10734973999",
	["lucide-sun-snow"] = "rbxassetid://10734974130",
	["lucide-sunrise"] = "rbxassetid://10734974522",
	["lucide-sunset"] = "rbxassetid://10734974689",
	["lucide-superscript"] = "rbxassetid://10734974850",
	["lucide-swiss-franc"] = "rbxassetid://10734975024",
	["lucide-switch-camera"] = "rbxassetid://10734975214",
	["lucide-sword"] = "rbxassetid://10734975486",
	["lucide-swords"] = "rbxassetid://10734975692",
	["lucide-syringe"] = "rbxassetid://10734975932",
	["lucide-table"] = "rbxassetid://10734976230",
	["lucide-table-2"] = "rbxassetid://10734976097",
	["lucide-tablet"] = "rbxassetid://10734976394",
	["lucide-tag"] = "rbxassetid://10734976528",
	["lucide-tags"] = "rbxassetid://10734976739",
	["lucide-target"] = "rbxassetid://10734977012",
	["lucide-tent"] = "rbxassetid://10734981750",
	["lucide-terminal"] = "rbxassetid://10734982144",
	["lucide-terminal-square"] = "rbxassetid://10734981995",
	["lucide-text-cursor"] = "rbxassetid://10734982395",
	["lucide-text-cursor-input"] = "rbxassetid://10734982297",
	["lucide-thermometer"] = "rbxassetid://10734983134",
	["lucide-thermometer-snowflake"] = "rbxassetid://10734982571",
	["lucide-thermometer-sun"] = "rbxassetid://10734982771",
	["lucide-thumbs-down"] = "rbxassetid://10734983359",
	["lucide-thumbs-up"] = "rbxassetid://10734983629",
	["lucide-ticket"] = "rbxassetid://10734983868",
	["lucide-timer"] = "rbxassetid://10734984606",
	["lucide-timer-off"] = "rbxassetid://10734984138",
	["lucide-timer-reset"] = "rbxassetid://10734984355",
	["lucide-toggle-left"] = "rbxassetid://10734984834",
	["lucide-toggle-right"] = "rbxassetid://10734985040",
	["lucide-tornado"] = "rbxassetid://10734985247",
	["lucide-toy-brick"] = "rbxassetid://10747361919",
	["lucide-train"] = "rbxassetid://10747362105",
	["lucide-trash"] = "rbxassetid://10747362393",
	["lucide-trash-2"] = "rbxassetid://10747362241",
	["lucide-tree-deciduous"] = "rbxassetid://10747362534",
	["lucide-tree-pine"] = "rbxassetid://10747362748",
	["lucide-trees"] = "rbxassetid://10747363016",
	["lucide-trending-down"] = "rbxassetid://10747363205",
	["lucide-trending-up"] = "rbxassetid://10747363465",
	["lucide-triangle"] = "rbxassetid://10747363621",
	["lucide-trophy"] = "rbxassetid://10747363809",
	["lucide-truck"] = "rbxassetid://10747364031",
	["lucide-tv"] = "rbxassetid://10747364593",
	["lucide-tv-2"] = "rbxassetid://10747364302",
	["lucide-type"] = "rbxassetid://10747364761",
	["lucide-umbrella"] = "rbxassetid://10747364971",
	["lucide-underline"] = "rbxassetid://10747365191",
	["lucide-undo"] = "rbxassetid://10747365484",
	["lucide-undo-2"] = "rbxassetid://10747365359",
	["lucide-unlink"] = "rbxassetid://10747365771",
	["lucide-unlink-2"] = "rbxassetid://10747397871",
	["lucide-unlock"] = "rbxassetid://10747366027",
	["lucide-upload"] = "rbxassetid://10747366434",
	["lucide-upload-cloud"] = "rbxassetid://10747366266",
	["lucide-usb"] = "rbxassetid://10747366606",
	["lucide-user"] = "rbxassetid://10747373176",
	["lucide-user-check"] = "rbxassetid://10747371901",
	["lucide-user-cog"] = "rbxassetid://10747372167",
	["lucide-user-minus"] = "rbxassetid://10747372346",
	["lucide-user-plus"] = "rbxassetid://10747372702",
	["lucide-user-x"] = "rbxassetid://10747372992",
	["lucide-users"] = "rbxassetid://10747373426",
	["lucide-utensils"] = "rbxassetid://10747373821",
	["lucide-utensils-crossed"] = "rbxassetid://10747373629",
	["lucide-venetian-mask"] = "rbxassetid://10747374003",
	["lucide-verified"] = "rbxassetid://10747374131",
	["lucide-vibrate"] = "rbxassetid://10747374489",
	["lucide-vibrate-off"] = "rbxassetid://10747374269",
	["lucide-video"] = "rbxassetid://10747374938",
	["lucide-video-off"] = "rbxassetid://10747374721",
	["lucide-view"] = "rbxassetid://10747375132",
	["lucide-voicemail"] = "rbxassetid://10747375281",
	["lucide-volume"] = "rbxassetid://10747376008",
	["lucide-volume-1"] = "rbxassetid://10747375450",
	["lucide-volume-2"] = "rbxassetid://10747375679",
	["lucide-volume-x"] = "rbxassetid://10747375880",
	["lucide-wallet"] = "rbxassetid://10747376205",
	["lucide-wand"] = "rbxassetid://10747376565",
	["lucide-wand-2"] = "rbxassetid://10747376349",
	["lucide-watch"] = "rbxassetid://10747376722",
	["lucide-waves"] = "rbxassetid://10747376931",
	["lucide-webcam"] = "rbxassetid://10747381992",
	["lucide-wifi"] = "rbxassetid://10747382504",
	["lucide-wifi-off"] = "rbxassetid://10747382268",
	["lucide-wind"] = "rbxassetid://10747382750",
	["lucide-wrap-text"] = "rbxassetid://10747383065",
	["lucide-wrench"] = "rbxassetid://10747383470",
	["lucide-x"] = "rbxassetid://10747384394",
	["lucide-x-circle"] = "rbxassetid://10747383819",
	["lucide-x-octagon"] = "rbxassetid://10747384037",
	["lucide-x-square"] = "rbxassetid://10747384217",
	["lucide-zoom-in"] = "rbxassetid://10747384552",
	["lucide-zoom-out"] = "rbxassetid://10747384679",
};

------------------ CREATE WINDOW --------------------
function NguyenMinhNhat.new(self)
	self.Title = self.Title or "Harmony";
	self.Scale = self.Scale or UDim2.new(0, 500, 0, 345);
	self.Keybind = self.Keybind or Enum.KeyCode.LeftAlt;

	self.Toggle = true;
	self.Cache = {};
	self.SelectedTab = nil;
	self.Cache.Tab = {};
	self.Dropdown = {};

	local SpyderXLib = Instance.new("ScreenGui")
	local WindowFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local DropShadow = Instance.new("ImageLabel")
	local Headers = Instance.new("Frame")
	local WindowText = Instance.new("TextLabel")
	local Frame = Instance.new("Frame")
	local MinButton = Instance.new("ImageButton")
	local CloseButton = Instance.new("ImageButton")
	local UIListLayout = Instance.new("UIListLayout")
	local HeadLine = Instance.new("Frame")
	local TabInputs = Instance.new("Frame")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout_2 = Instance.new("UIListLayout")
	local HeadLine_2 = Instance.new("Frame")
	local TabFrames = Instance.new("Frame")

	SpyderXLib.Parent = CoreGui:FindFirstChild('RobloxGui') or CoreGui;
	SpyderXLib.ResetOnSpawn = false
	SpyderXLib.IgnoreGuiInset = true
	SpyderXLib.ZIndexBehavior = Enum.ZIndexBehavior.Global
	SpyderXLib.Name = NguyenMinhNhat:ChiuMyLy();

	if protect_gui or protectgui then
		(protect_gui or protectgui)(SpyderXLib);
	end;

	task.delay(1,function()
		for index = 1 , math.random(55,100) do task.wait();
			local folder = Instance.new('Folder',SpyderXLib);

			folder.Name = NguyenMinhNhat:ChiuMyLy();

			Instance.new('ModuleScript',folder).Name = NguyenMinhNhat:ChiuMyLy();
			Instance.new('BindableEvent',folder).Name = NguyenMinhNhat:ChiuMyLy();
		end;

		for index = 1 , math.random(55,100) do task.wait();
			local folder = Instance.new('Folder',WindowFrame);

			folder.Name = NguyenMinhNhat:ChiuMyLy();

			Instance.new('ModuleScript',folder).Name = NguyenMinhNhat:ChiuMyLy();
			Instance.new('BindableEvent',folder).Name = NguyenMinhNhat:ChiuMyLy();
		end;
	end)

	self.Root = SpyderXLib;

	WindowFrame.Name = NguyenMinhNhat:ChiuMyLy();
	WindowFrame.Parent = SpyderXLib
	WindowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	WindowFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	WindowFrame.BackgroundTransparency = 0.040
	WindowFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	WindowFrame.BorderSizePixel = 0
	WindowFrame.ClipsDescendants = true
	WindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	WindowFrame.Size = UDim2.fromOffset(0,22)
	WindowFrame.Active = true

	TweenSv:Create(WindowFrame , TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
		Size = UDim2.new(self.Scale.X.Scale,self.Scale.X.Offset,0,21)
	}):Play()

	task.delay(1,function()
		TweenSv:Create(WindowFrame , TweenInfo.new(1.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
			Size = self.Scale
		}):Play();

		TweenSv:Create(DropShadow,TweenInfo.new(2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
			ImageTransparency = 0.5
		}):Play();
	end)

	NguyenMinhNhat:SetBlur(WindowFrame,true);

	UICorner.CornerRadius = UDim.new(0, 4)
	UICorner.Parent = WindowFrame
	UICorner.Name = NguyenMinhNhat:ChiuMyLy();

	DropShadow.Name = NguyenMinhNhat:ChiuMyLy();
	DropShadow.Parent = WindowFrame
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1.000
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Rotation = 0.010
	DropShadow.Size = UDim2.new(1, 47, 1, 47)
	DropShadow.ZIndex = 0
	DropShadow.Image = (NguyenMinhNhat.EnableIcon and "rbxassetid://6015897843") or "";
	DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	DropShadow.ImageTransparency = 1
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
	DropShadow.Name = NguyenMinhNhat:ChiuMyLy();

	Headers.Name = NguyenMinhNhat:ChiuMyLy();
	Headers.Parent = WindowFrame
	Headers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Headers.BackgroundTransparency = 1.000
	Headers.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Headers.BorderSizePixel = 0
	Headers.Size = UDim2.new(1, 0, 0, 22)
	Headers.ZIndex = 5
	Headers.Name = NguyenMinhNhat:ChiuMyLy();

	WindowText.Name = NguyenMinhNhat:ChiuMyLy();
	WindowText.Parent = Headers
	WindowText.AnchorPoint = Vector2.new(0, 0.5)
	WindowText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WindowText.BackgroundTransparency = 1.000
	WindowText.BorderColor3 = Color3.fromRGB(0, 0, 0)
	WindowText.BorderSizePixel = 0
	WindowText.Position = UDim2.new(-0.1, 4, 0.5, 0)
	WindowText.Size = UDim2.new(1, -45, 0.5, 0)
	WindowText.Font = Enum.Font.GothamMedium
	WindowText.Text = self.Title
	WindowText.TextColor3 = Color3.fromRGB(223, 223, 223)
	WindowText.TextSize = 12.000
	WindowText.TextXAlignment = Enum.TextXAlignment.Left
	WindowText.TextTransparency = 1;
	WindowText.RichText = true
	WindowText.Name = NguyenMinhNhat:ChiuMyLy();

	TweenSv:Create(WindowText,TweenInfo.new(2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
		TextTransparency = 0,
		Position = UDim2.new(0, 4, 0.5, 0)
	}):Play();

	Frame.Parent = Headers
	Frame.AnchorPoint = Vector2.new(1, 0.5)
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Frame.BackgroundTransparency = 1.000
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(1, -4, 0.5, 0)
	Frame.Size = UDim2.new(0, 55, 0.5, 0)
	Frame.ZIndex = 4
	Frame.Name = NguyenMinhNhat:ChiuMyLy();

	UIListLayout.Parent = Frame
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.Padding = UDim.new(0, 5)
	UIListLayout.Name = NguyenMinhNhat:ChiuMyLy();

	MinButton.Name = NguyenMinhNhat:ChiuMyLy();
	MinButton.Parent = Frame
	MinButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MinButton.BackgroundTransparency = 1.000
	MinButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MinButton.BorderSizePixel = 0
	MinButton.Size = UDim2.new(1, 0, 1, 0)
	MinButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	MinButton.ZIndex = 25

	if NguyenMinhNhat.EnableIcon then
		MinButton.Image = "rbxassetid://9886659276";	
	else
		NguyenMinhNhat.CreateEmuIcon(MinButton , "-")
	end

	MinButton.Active = true



	CloseButton.Name = NguyenMinhNhat:ChiuMyLy();
	CloseButton.Parent = Frame
	CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.BackgroundTransparency = 1.000
	CloseButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	CloseButton.BorderSizePixel = 0
	CloseButton.Size = UDim2.new(1, 0, 1, 0)
	CloseButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	CloseButton.ZIndex = 6

	if NguyenMinhNhat.EnableIcon then
		CloseButton.Image = "rbxassetid://9886659671"
	else
		NguyenMinhNhat.CreateEmuIcon(CloseButton , "X")
	end

	HeadLine.Name = NguyenMinhNhat:ChiuMyLy();
	HeadLine.Parent = Headers
	HeadLine.AnchorPoint = Vector2.new(0, 1)
	HeadLine.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	HeadLine.BackgroundTransparency = 0.050
	HeadLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HeadLine.BorderSizePixel = 0
	HeadLine.Position = UDim2.new(0, 0, 1, 0)
	HeadLine.Size = UDim2.new(1, 0, 0, 1)
	HeadLine.ZIndex = 4

	TabInputs.Name = NguyenMinhNhat:ChiuMyLy();
	TabInputs.Parent = WindowFrame
	TabInputs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabInputs.BackgroundTransparency = 1.000
	TabInputs.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabInputs.BorderSizePixel = 0
	TabInputs.ClipsDescendants = true
	TabInputs.Position = UDim2.new(0, 0, 0, 23)
	TabInputs.Size = UDim2.new(0, 145, 1, -22)

	ScrollingFrame.Parent = TabInputs
	ScrollingFrame.Active = true
	ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 1.000
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.ClipsDescendants = false
	ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	ScrollingFrame.Size = UDim2.new(1, -2, 1, -2)
	ScrollingFrame.ScrollBarThickness = 0
	ScrollingFrame.Name = NguyenMinhNhat:ChiuMyLy();

	UIListLayout_2.Parent = ScrollingFrame
	UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2.Padding = UDim.new(0, 100)
	UIListLayout_2.Name = NguyenMinhNhat:ChiuMyLy();

	UIListLayout_2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		ScrollingFrame.CanvasSize = UDim2.new(0,0,0,UIListLayout_2.AbsoluteContentSize.Y + 10)
	end)

	task.delay(1,function()
		TweenSv:Create(UIListLayout_2 , TweenInfo.new(1.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
			Padding = UDim.new(0, 2)
		}):Play();
	end);

	HeadLine_2.Name = NguyenMinhNhat:ChiuMyLy();
	HeadLine_2.Parent = TabInputs
	HeadLine_2.AnchorPoint = Vector2.new(1, 0)
	HeadLine_2.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	HeadLine_2.BackgroundTransparency = 0.050
	HeadLine_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HeadLine_2.BorderSizePixel = 0
	HeadLine_2.Position = UDim2.new(1, 0, 0, -1)
	HeadLine_2.Size = UDim2.new(0, 1, 1, 0)
	HeadLine_2.ZIndex = 4

	TabFrames.Name = NguyenMinhNhat:ChiuMyLy();
	TabFrames.Parent = WindowFrame
	TabFrames.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabFrames.BackgroundTransparency = 1.000
	TabFrames.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabFrames.BorderSizePixel = 0
	TabFrames.Position = UDim2.new(0, 145, 0, 22)
	TabFrames.Size = UDim2.new(1, -145, 1, -22)
	TabFrames.ZIndex = 4

	do
		self.Dropdown.Visible = false;

		local DropdownFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local ScrollingFrame = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")

		DropdownFrame.Name = NguyenMinhNhat:ChiuMyLy();
		DropdownFrame.Parent = SpyderXLib;
		DropdownFrame.AnchorPoint = Vector2.new(0.5, 1)
		DropdownFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		DropdownFrame.BackgroundTransparency = 0.040
		DropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		DropdownFrame.BorderSizePixel = 0
		DropdownFrame.ClipsDescendants = true
		DropdownFrame.Position = UDim2.new(0.832101822, 0, 0.638923645, 0)
		DropdownFrame.Size = UDim2.new(0, 153, 0, 0)
		DropdownFrame.ZIndex = 55
		DropdownFrame.Visible = false;

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = DropdownFrame

		ScrollingFrame.Parent = DropdownFrame
		ScrollingFrame.Active = true
		ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollingFrame.BackgroundTransparency = 1.000
		ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ScrollingFrame.BorderSizePixel = 0
		ScrollingFrame.ClipsDescendants = false
		ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		ScrollingFrame.Size = UDim2.new(1, -5, 1, -10)
		ScrollingFrame.ZIndex = 56
		ScrollingFrame.ScrollBarThickness = 1
		ScrollingFrame.Name = NguyenMinhNhat:ChiuMyLy();

		UIListLayout.Parent = ScrollingFrame
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 4)
		UIListLayout.Name = NguyenMinhNhat:ChiuMyLy();

		UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
		end)

		local DropdownSyyu = {};
		local IsHover = false;

		local CreateButton = function(name : string) : Frame
			local bth = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local UIGradient = Instance.new("UIGradient")
			local UIStroke = Instance.new("UIStroke")
			local PText = Instance.new("TextLabel")

			bth.Name = NguyenMinhNhat:ChiuMyLy();
			bth.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			bth.BorderColor3 = Color3.fromRGB(0, 0, 0)
			bth.BorderSizePixel = 0
			bth.Size = UDim2.new(1, -5, 0, 20)
			bth.ZIndex = 57

			UICorner.CornerRadius = UDim.new(0, 3)
			UICorner.Parent = bth

			UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.81, Color3.fromRGB(195, 195, 195)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(186, 186, 186))}
			UIGradient.Rotation = 90
			UIGradient.Parent = bth

			UIStroke.Parent = bth
			UIStroke.Color = Color3.fromRGB(172, 172, 172)
			UIStroke.Transparency = 0.900

			PText.Name = NguyenMinhNhat:ChiuMyLy();
			PText.Parent = bth
			PText.AnchorPoint = Vector2.new(0, 0.5)
			PText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			PText.BackgroundTransparency = 1.000
			PText.BorderColor3 = Color3.fromRGB(0, 0, 0)
			PText.BorderSizePixel = 0
			PText.Position = UDim2.new(0, 5, 0.5, 0)
			PText.Size = UDim2.new(1, -10, 0.5, 0)
			PText.ZIndex = 58
			PText.Font = Enum.Font.GothamMedium
			PText.Text = tostring(name)
			PText.TextColor3 = Color3.fromRGB(255, 255, 255)
			PText.TextSize = 9.000
			PText.TextTransparency = 0.200
			PText.TextXAlignment = Enum.TextXAlignment.Left
			PText.RichText = true

			return bth;
		end;

		function DropdownSyyu:Init(data : {string | any}, Default : string | any, Multi : boolean, BaseFrame : Frame , Callback : any , SearchBar : boolean)
			DropdownSyyu.Data = data;
			DropdownSyyu.Multi = Multi;	
			DropdownSyyu.BaseFrame = BaseFrame;
			DropdownSyyu.Visible = true;
			DropdownSyyu.SearchBar = SearchBar;
			
			for i,v in next , ScrollingFrame:GetChildren() do
				if v:IsA('Frame') then
					v:Destroy();
				end;
			end;

			local Selecteds = {};

			for i,v in next , data do
				local TextFrame = CreateButton(v);
				local Button = NguyenMinhNhat:NewInput(TextFrame);

				TextFrame.Parent = ScrollingFrame;

				if not Multi then
					if v == Default then
						TextFrame.BackgroundColor3 = Color3.fromRGB(61, 149, 204);
						Selecteds[1] = TextFrame;
					end;
				else
					if typeof(Default) == 'table' and (Default[v] or table.find(Default,v)) then
						TextFrame.BackgroundColor3 = Color3.fromRGB(61, 149, 204);
						Selecteds[v] = true
					else
						if v == Default then
							TextFrame.BackgroundColor3 = Color3.fromRGB(61, 149, 204);
							Selecteds[v] = true
						end;
					end;
				end;

				Button.MouseButton1Click:Connect(function()
					if Multi then
						Selecteds[v] = not Selecteds[v];

						if Selecteds[v] then
							TweenSv:Create(TextFrame,TweenInfo.new(0.1),{
								BackgroundColor3 = Color3.fromRGB(61, 149, 204)
							}):Play();
						else
							TweenSv:Create(TextFrame,TweenInfo.new(0.1),{
								BackgroundColor3 = Color3.fromRGB(45, 45, 45)
							}):Play();
						end;

						Callback(Selecteds);
					else
						if Selecteds[1] then
							TweenSv:Create(Selecteds[1],TweenInfo.new(0.1),{
								BackgroundColor3 = Color3.fromRGB(45, 45, 45)
							}):Play();
						end;

						TweenSv:Create(TextFrame,TweenInfo.new(0.1),{
							BackgroundColor3 = Color3.fromRGB(61, 149, 204)
						}):Play()

						Selecteds[1] = TextFrame;

						Callback(v);
					end;
				end);
			end;
		end;

		function DropdownSyyu:Close()
			DropdownSyyu.Visible = false;

			IsHover = false;
		end;

		DropdownFrame.MouseEnter:Connect(function()
			IsHover = true;
		end)

		DropdownFrame.MouseLeave:Connect(function()
			IsHover = false;
		end)

		UserInputSv.InputBegan:Connect(function(Input : InputObject , IsTyping : boolean)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				if not IsHover then
					DropdownSyyu:Close();
				end;
			end;
		end);

		do
			local SearchBar = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local TextBox = Instance.new("TextBox")

			SearchBar.Name = NguyenMinhNhat:ChiuMyLy()
			SearchBar.Parent = SpyderXLib
			SearchBar.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
			SearchBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SearchBar.BorderSizePixel = 0
			SearchBar.ClipsDescendants = true
			SearchBar.Position = UDim2.new(0.624000013, 0, 0.439999998, 0)
			SearchBar.Size = UDim2.new(0, 153, 0, 25)
			SearchBar.ZIndex = 54

			UICorner.CornerRadius = UDim.new(0, 4)
			UICorner.Parent = SearchBar
			
			TextBox.Name = NguyenMinhNhat:ChiuMyLy();
			TextBox.Parent = SearchBar
			TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
			TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextBox.BackgroundTransparency = 1.000
			TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextBox.BorderSizePixel = 0
			TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
			TextBox.Size = UDim2.new(1, -5, 1, -5)
			TextBox.ClearTextOnFocus = false
			TextBox.Font = Enum.Font.GothamMedium
			TextBox.PlaceholderText = "Search"
			TextBox.Text = ""
			TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextBox.TextSize = 11.000
			TextBox.ZIndex = 55
			
			SearchBar.MouseEnter:Connect(function()
				IsHover = true;
			end)

			SearchBar.MouseLeave:Connect(function()
				IsHover = false;
			end)
			
			TextBox.Focused:Connect(function()
				IsHover = true;
			end)
			
			TextBox.FocusLost:Connect(function()
				IsHover = true;
			end)
			
			TextBox:GetPropertyChangedSignal('Text'):Connect(function()
				if TextBox.Text:byte() then
					if DropdownSyyu.Visible then
						for i,v in next , ScrollingFrame:GetChildren() do
							if (i % 50) == 1 then
								task.wait();
							end;
							
							if v:IsA('Frame') then
								local Text = v:FindFirstChildWhichIsA('TextLabel',true);
								
								if Text then
									if string.find(string.lower(Text.Text) , string.lower(TextBox.Text) ,1 , true) then
										v.Visible = true;
									else
										v.Visible = false;
									end;
								end;
							end;
						end;
					end;
				else
					
					for i,v in next , ScrollingFrame:GetChildren() do
						if (i % 50) == 1 then
							task.wait();
						end;

						if v:IsA('Frame') then
							v.Visible = true
						end;
					end;
				end;
			end)
			
			RunService:BindToRenderStep("__DROPDOWN_INIT__"..NguyenMinhNhat:ChiuMyLy(),56,function()
				if DropdownSyyu.Visible then
					
					
					local BaseFrame : Frame = DropdownSyyu.BaseFrame;

					TweenSv:Create(DropdownFrame,TweenInfo.new(0.15),{
						Size = UDim2.new(0, 153, 0, math.clamp(UIListLayout.AbsoluteContentSize.Y + 11,11,350)),
						Position = UDim2.fromOffset(BaseFrame.AbsolutePosition.X + (BaseFrame.AbsoluteSize.X / 2),BaseFrame.AbsolutePosition.Y + math.abs(SpyderXLib.AbsolutePosition.Y))
					}):Play();
					
					if DropdownSyyu.SearchBar then
						SearchBar.Visible = true;
						
						local yBase = (BaseFrame.AbsolutePosition.Y + math.abs(SpyderXLib.AbsolutePosition.Y)) - DropdownFrame.AbsoluteSize.Y;

						TweenSv:Create(SearchBar,TweenInfo.new(0.15),{
							Size = UDim2.new(0, DropdownFrame.AbsoluteSize.X, 0, 25),
							Position = UDim2.fromOffset(DropdownFrame.AbsolutePosition.X,yBase - 30)
						}):Play();
					else
						SearchBar.Visible = false;
					end;
				else
					
					TextBox.Text = "";
					SearchBar.Visible = false;
					SearchBar.Position = UDim2.fromOffset(DropdownFrame.AbsolutePosition.X,DropdownFrame.AbsolutePosition.Y);
					
					TweenSv:Create(DropdownFrame,TweenInfo.new(0.15),{
						Size = UDim2.new(0, 153, 0, 0),
					}):Play();
				end;

				if DropdownFrame.Size.Y.Offset <= 3 then
					DropdownFrame.Visible = false;
				else
					DropdownFrame.Visible = true;
				end;
			end);
		end;

		self.Dropdown = DropdownSyyu;
	end;

	local DropdownSyu = self.Dropdown; -- im lazy + dumbass

	------------------ CREATE TAB -------------------
	function self:AddTab(obj)
		obj.Icon = obj.Icon or NguyenMinhNhat.Assets["lucide-sun"];
		obj.Title = obj.Title or "Tab";
		obj.SelectedSeciton = nil;
		obj.Cache = {};

		------------------- BUTTON -----------------
		local TabButton = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local PText = Instance.new("TextLabel")
		local Icon = Instance.new("ImageLabel")
		local UIGradient = Instance.new("UIGradient")
		local UIGradient_2 = Instance.new("UIGradient")

		TabButton.Name = NguyenMinhNhat:ChiuMyLy();
		TabButton.Parent = ScrollingFrame;
		TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		TabButton.BackgroundTransparency = 0.500
		TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, -3, 0, 30)
		TabButton.ZIndex = 7

		UICorner.CornerRadius = UDim.new(0, 3)
		UICorner.Parent = TabButton

		PText.Name = NguyenMinhNhat:ChiuMyLy();
		PText.Parent = TabButton
		PText.AnchorPoint = Vector2.new(0, 0.5)
		PText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		PText.BackgroundTransparency = 1.000
		PText.BorderColor3 = Color3.fromRGB(0, 0, 0)
		PText.BorderSizePixel = 0
		PText.Position = UDim2.new(0, 32, 0.5, 0)
		PText.Size = UDim2.new(1, -22, 0.5, 0)
		PText.ZIndex = 8
		PText.Font = Enum.Font.GothamMedium
		PText.Text = obj.Title
		PText.TextColor3 = Color3.fromRGB(255, 255, 255)
		PText.TextSize = 12.000
		PText.TextTransparency = 0.500
		PText.TextXAlignment = Enum.TextXAlignment.Left
		PText.RichText = true

		Icon.Name = NguyenMinhNhat:ChiuMyLy();
		Icon.Parent = TabButton
		Icon.AnchorPoint = Vector2.new(0, 0.5)
		Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Icon.BackgroundTransparency = 1.000
		Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon.BorderSizePixel = 0
		Icon.Position = UDim2.new(0, 5, 0.5, 0)
		Icon.Size = UDim2.new(0.699999988, 0, 0.699999988, 0)
		Icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		Icon.ZIndex = 8
		if NguyenMinhNhat.EnableIcon then
			Icon.Image = NguyenMinhNhat.Assets[obj.Icon] or NguyenMinhNhat.Assets["lucide-"..obj.Icon] or obj.Icon;
		else
			Icon.Visible = false;
			PText.Position = UDim2.new(0, 8, 0.5, 0)
		end;

		UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.81, Color3.fromRGB(195, 195, 195)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(186, 186, 186))}
		UIGradient.Rotation = 90
		UIGradient.Parent = Icon

		UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.81, Color3.fromRGB(195, 195, 195)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(186, 186, 186))}
		UIGradient_2.Rotation = 90
		UIGradient_2.Parent = TabButton

		--------------------- Main Frame -----------------------

		local TabBlock = Instance.new("Frame")
		local TabHeaders = Instance.new("Frame")
		local SectionScroll = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")
		local HeadLine = Instance.new("Frame")
		local SrcFrame = Instance.new("Frame")

		TabBlock.Name = NguyenMinhNhat:ChiuMyLy();
		TabBlock.Parent = TabFrames
		TabBlock.AnchorPoint = Vector2.new(0.5, 0.5)
		TabBlock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabBlock.BackgroundTransparency = 1.000
		TabBlock.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabBlock.BorderSizePixel = 0
		TabBlock.Position = UDim2.new(0.5, 0, 0.5, 0)
		TabBlock.Size = UDim2.new(1, 0, 1, 0)
		TabBlock.ZIndex = 10

		TabHeaders.Name = NguyenMinhNhat:ChiuMyLy();
		TabHeaders.Parent = TabBlock
		TabHeaders.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabHeaders.BackgroundTransparency = 1.000
		TabHeaders.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabHeaders.BorderSizePixel = 0
		TabHeaders.ClipsDescendants = true
		TabHeaders.Size = UDim2.new(1, 0, 0, 23)

		SectionScroll.Name = NguyenMinhNhat:ChiuMyLy();
		SectionScroll.Parent = TabHeaders
		SectionScroll.Active = true
		SectionScroll.AnchorPoint = Vector2.new(0.5, 0.5)
		SectionScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SectionScroll.BackgroundTransparency = 1.000
		SectionScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SectionScroll.BorderSizePixel = 0
		SectionScroll.ClipsDescendants = false
		SectionScroll.Position = UDim2.new(0.5, 0, 0.5, 0)
		SectionScroll.Size = UDim2.new(1, -4, 1, -1)
		SectionScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
		SectionScroll.CanvasSize = UDim2.new(2, 0, 0, 0)
		SectionScroll.ScrollBarThickness = 0

		UIListLayout.Parent = SectionScroll
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		UIListLayout.Padding = UDim.new(0, 100)

		UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			SectionScroll.CanvasSize = UDim2.new(0,UIListLayout.AbsoluteContentSize.X + 10,0,0)
		end)

		task.delay(1,function()
			TweenSv:Create(UIListLayout , TweenInfo.new(1.3,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
				Padding = UDim.new(0, 4)
			}):Play();
		end);

		HeadLine.Name = NguyenMinhNhat:ChiuMyLy();
		HeadLine.Parent = TabBlock
		HeadLine.AnchorPoint = Vector2.new(0, 1)
		HeadLine.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
		HeadLine.BackgroundTransparency = 0.050
		HeadLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
		HeadLine.BorderSizePixel = 0
		HeadLine.Position = UDim2.new(0, 0, 0, 24)
		HeadLine.Size = UDim2.new(1, 0, 0, 1)
		HeadLine.ZIndex = 4

		SrcFrame.Name = NguyenMinhNhat:ChiuMyLy();
		SrcFrame.Parent = TabBlock
		SrcFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SrcFrame.BackgroundTransparency = 1.000
		SrcFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SrcFrame.BorderSizePixel = 0
		SrcFrame.ClipsDescendants = true
		SrcFrame.Position = UDim2.new(0, 0, 0, 24)
		SrcFrame.Size = UDim2.new(1, 0, 1, -23)
		SrcFrame.ZIndex = 9

		---------------- CREATE SECTION  ---------------
		function obj:AddSection(dick)
			dick = dick or {};
			dick.Title = dick.Title or "Section";

			local SectionInput = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local UIStroke = Instance.new("UIStroke")
			local Label = Instance.new("TextLabel")
			local UIGradient = Instance.new("UIGradient")

			SectionInput.Name = NguyenMinhNhat:ChiuMyLy();
			SectionInput.Parent = SectionScroll;
			SectionInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			SectionInput.BackgroundTransparency = 0.200
			SectionInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionInput.BorderSizePixel = 0
			SectionInput.ClipsDescendants = true
			SectionInput.Size = UDim2.new(0, 65, 0.899999976, 0)
			SectionInput.ZIndex = 7

			UICorner.CornerRadius = UDim.new(0, 2)
			UICorner.Parent = SectionInput

			UIStroke.Parent = SectionInput
			UIStroke.Color = Color3.fromRGB(172, 172, 172)
			UIStroke.Transparency = 0.890

			Label.Name = NguyenMinhNhat:ChiuMyLy();
			Label.Parent = SectionInput
			Label.AnchorPoint = Vector2.new(0.5, 0.5)
			Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Label.BackgroundTransparency = 1.000
			Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Label.BorderSizePixel = 0
			Label.Position = UDim2.new(0.5, 0, 0.5, 0)
			Label.Size = UDim2.new(1, -5, 0.600000024, 0)
			Label.ZIndex = 8
			Label.Font = Enum.Font.GothamMedium
			Label.Text = dick.Title
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.TextSize = 11.000
			Label.TextTransparency = 0.200
			Label.RichText = true

			UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(243, 243, 243))}
			UIGradient.Rotation = 90
			UIGradient.Parent = SectionInput

			local LabelScale = TextSv:GetTextSize(Label.Text,Label.TextSize,Label.Font,Vector2.new(math.huge,math.huge));

			TweenSv:Create(SectionInput,TweenInfo.new(0.1),{
				Size = UDim2.new(0, LabelScale.X + 10, 0.899999976, 0)
			}):Play()

			local SectionMainFrame = Instance.new("ScrollingFrame")
			local UIListLayout = Instance.new("UIListLayout")

			SectionMainFrame.Name = NguyenMinhNhat:ChiuMyLy();
			SectionMainFrame.Parent = SrcFrame
			SectionMainFrame.Active = true
			SectionMainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			SectionMainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionMainFrame.BackgroundTransparency = 1.000
			SectionMainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionMainFrame.BorderSizePixel = 0
			SectionMainFrame.ClipsDescendants = false
			SectionMainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			SectionMainFrame.Size = UDim2.new(1, -1, 1, -4)
			SectionMainFrame.ZIndex = 15
			SectionMainFrame.ScrollBarThickness = 1

			UIListLayout.Parent = SectionMainFrame
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 150)

			UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				SectionMainFrame.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y + 10)
			end)

			task.delay(1,function()
				TweenSv:Create(UIListLayout , TweenInfo.new(1.75,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
					Padding = UDim.new(0, 4)
				}):Play();
			end);

			do
				-------------- Toggle -------------
				function dick:AddToggle(femboy)
					femboy = femboy or {};

					femboy.Title = femboy.Title or "Toggle";
					femboy.Default = femboy.Default or false;
					femboy.Callback = femboy.Callback or function() end;

					local ToggleSrc = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local UIStroke = Instance.new("UIStroke")
					local UIGradient = Instance.new("UIGradient")
					local Label = Instance.new("TextLabel")
					local mv = Instance.new("Frame")
					local UICorner_2 = Instance.new("UICorner")
					local UIStroke_2 = Instance.new("UIStroke")
					local circle = Instance.new("Frame")
					local UICorner_3 = Instance.new("UICorner")

					ToggleSrc.Name = NguyenMinhNhat:ChiuMyLy();
					ToggleSrc.Parent = SectionMainFrame
					ToggleSrc.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					ToggleSrc.BackgroundTransparency = 0.150
					ToggleSrc.BorderColor3 = Color3.fromRGB(0, 0, 0)
					ToggleSrc.BorderSizePixel = 0
					ToggleSrc.ClipsDescendants = true
					ToggleSrc.Size = UDim2.new(1, -5, 0, 30)
					ToggleSrc.ZIndex = 11

					UICorner.CornerRadius = UDim.new(0, 2)
					UICorner.Parent = ToggleSrc

					UIStroke.Parent = ToggleSrc
					UIStroke.Color = Color3.fromRGB(172, 172, 172)
					UIStroke.Transparency = 0.890

					UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(243, 243, 243))}
					UIGradient.Rotation = 90
					UIGradient.Parent = ToggleSrc

					Label.Name = NguyenMinhNhat:ChiuMyLy();
					Label.Parent = ToggleSrc
					Label.AnchorPoint = Vector2.new(0, 0.5)
					Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Label.BackgroundTransparency = 1.000
					Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Label.BorderSizePixel = 0
					Label.Position = UDim2.new(0, 5, 0.5, 0)
					Label.Size = UDim2.new(1, -65, 0.5, 0)
					Label.ZIndex = 12
					Label.Font = Enum.Font.GothamMedium
					Label.Text = femboy.Title
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 12.000
					Label.TextTransparency = 0.200
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.RichText = true

					mv.Name = NguyenMinhNhat:ChiuMyLy();
					mv.Parent = ToggleSrc
					mv.AnchorPoint = Vector2.new(1, 0.5)
					mv.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					mv.BorderColor3 = Color3.fromRGB(0, 0, 0)
					mv.BorderSizePixel = 0
					mv.Position = UDim2.new(1, -5, 0.5, 0)
					mv.Size = UDim2.new(0, 40, 0.600000024, 0)
					mv.ZIndex = 12

					UICorner_2.CornerRadius = UDim.new(1, 0)
					UICorner_2.Parent = mv

					UIStroke_2.Parent = mv
					UIStroke_2.Color = Color3.fromRGB(172, 172, 172)
					UIStroke_2.Transparency = 0.890

					circle.Name = NguyenMinhNhat:ChiuMyLy();
					circle.Parent = mv
					circle.AnchorPoint = Vector2.new(0.5, 0.5)
					circle.BackgroundColor3 = Color3.fromRGB(0, 255, 238)
					circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
					circle.BorderSizePixel = 0
					circle.Position = UDim2.new(0.75, 0, 0.5, 0)
					circle.Size = UDim2.new(1, 0, 1, 0)
					circle.SizeConstraint = Enum.SizeConstraint.RelativeYY
					circle.ZIndex = 13

					UICorner_3.CornerRadius = UDim.new(1, 0)
					UICorner_3.Parent = circle

					local SetValue = function(val)
						if val then
							TweenSv:Create(circle,TweenInfo.new(0.3),{
								Position = UDim2.fromScale(0.75,0.5),
								BackgroundColor3 = Color3.fromRGB(0, 255, 238)
							}):Play()
						else
							TweenSv:Create(circle,TweenInfo.new(0.3),{
								Position = UDim2.fromScale(0.25,0.5),
								BackgroundColor3 = Color3.fromRGB(161, 161, 161)
							}):Play()
						end;
					end;

					SetValue(femboy.Default);

					local Button = NguyenMinhNhat:NewInput(ToggleSrc);

					Button.MouseButton1Click:Connect(function()
						femboy.Default = not femboy.Default;

						SetValue(femboy.Default);

						femboy.Callback(femboy.Default);
					end);

					function femboy:SetValue(a)
						femboy.Default = a;

						SetValue(femboy.Default);

						femboy.Callback(femboy.Default,true);
					end;

					function femboy:Destroy()
						ToggleSrc:Destroy();
					end;

					return femboy;
				end;


				------------- Button ------------
				function dick:AddButton(skidding)
					skidding = skidding or {};
					skidding.Title = skidding.Title or "Button";
					skidding.Callback = skidding.Callback or function() end;

					local ButtonSrc = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local UIStroke = Instance.new("UIStroke")
					local UIGradient = Instance.new("UIGradient")
					local Label = Instance.new("TextLabel")
					local Icon = Instance.new("ImageLabel")

					ButtonSrc.Name = NguyenMinhNhat:ChiuMyLy();
					ButtonSrc.Parent = SectionMainFrame;
					ButtonSrc.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					ButtonSrc.BackgroundTransparency = 0.150
					ButtonSrc.BorderColor3 = Color3.fromRGB(0, 0, 0)
					ButtonSrc.BorderSizePixel = 0
					ButtonSrc.ClipsDescendants = true
					ButtonSrc.Size = UDim2.new(1, -5, 0, 30)
					ButtonSrc.ZIndex = 11

					UICorner.CornerRadius = UDim.new(0, 2)
					UICorner.Parent = ButtonSrc

					UIStroke.Parent = ButtonSrc
					UIStroke.Color = Color3.fromRGB(172, 172, 172)
					UIStroke.Transparency = 0.890

					UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(243, 243, 243))}
					UIGradient.Rotation = 90
					UIGradient.Parent = ButtonSrc

					Label.Name = NguyenMinhNhat:ChiuMyLy();
					Label.Parent = ButtonSrc
					Label.AnchorPoint = Vector2.new(0, 0.5)
					Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Label.BackgroundTransparency = 1.000
					Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Label.BorderSizePixel = 0
					Label.Position = UDim2.new(0, 5, 0.5, 0)
					Label.Size = UDim2.new(1, -65, 0.5, 0)
					Label.ZIndex = 12
					Label.Font = Enum.Font.GothamMedium
					Label.Text = skidding.Title
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 12.000
					Label.TextTransparency = 0.4
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.RichText = true

					Icon.Name = NguyenMinhNhat:ChiuMyLy();
					Icon.Parent = ButtonSrc
					Icon.AnchorPoint = Vector2.new(1, 0.5)
					Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Icon.BackgroundTransparency = 1.000
					Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Icon.BorderSizePixel = 0
					Icon.Position = UDim2.new(1, -5, 0.5, 0)
					Icon.Size = UDim2.new(0.600000024, 0, 0.600000024, 0)
					Icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
					Icon.ZIndex = 13

					if NguyenMinhNhat.EnableIcon then
						Icon.Image = "rbxassetid://10709791437"
					else
						NguyenMinhNhat.CreateEmuIcon(Icon,'>')
					end;

					local Button = NguyenMinhNhat:NewInput(ButtonSrc);

					Button.MouseButton1Down:Connect(function()
						TweenSv:Create(Icon,TweenInfo.new(0.1),{
							Position = UDim2.new(1, -2, 0.5, 0)
						}):Play();
					end)

					Button.MouseButton1Up:Connect(function()
						TweenSv:Create(Icon,TweenInfo.new(0.1),{
							Position = UDim2.new(1, -5, 0.5, 0)
						}):Play();
					end)

					Button.MouseEnter:Connect(function()
						TweenSv:Create(Label,TweenInfo.new(0.1),{
							TextTransparency = 0.200
						}):Play();
					end)

					Button.MouseLeave:Connect(function()
						TweenSv:Create(Label,TweenInfo.new(0.1),{
							TextTransparency = 0.4
						}):Play();
					end)

					Button.MouseButton1Click:Connect(function()
						skidding.Callback(skidding)
					end)

					function skidding:Destroy()
						ButtonSrc:Destroy();
					end;

					function skidding:Fire(...)
						skidding.Callback(...)
					end;

					return skidding;
				end;

				-------------- PARAGRAPH --------------
				function dick:AddParagraph(ctx)
					ctx = ctx or {};
					ctx.Title = ctx.Title or "Paragraph";
					ctx.Content = ctx.Content or "Content";

					local ParagraphSrc = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local UIStroke = Instance.new("UIStroke")
					local UIGradient = Instance.new("UIGradient")
					local Title = Instance.new("TextLabel")
					local Content = Instance.new("TextLabel")

					ParagraphSrc.Name = NguyenMinhNhat:ChiuMyLy();
					ParagraphSrc.Parent = SectionMainFrame
					ParagraphSrc.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					ParagraphSrc.BackgroundTransparency = 0.150
					ParagraphSrc.BorderColor3 = Color3.fromRGB(0, 0, 0)
					ParagraphSrc.BorderSizePixel = 0
					ParagraphSrc.ClipsDescendants = true
					ParagraphSrc.Size = UDim2.new(1, -5, 0, 40)
					ParagraphSrc.ZIndex = 11

					UICorner.CornerRadius = UDim.new(0, 2)
					UICorner.Parent = ParagraphSrc

					UIStroke.Parent = ParagraphSrc
					UIStroke.Color = Color3.fromRGB(172, 172, 172)
					UIStroke.Transparency = 0.890

					UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(243, 243, 243))}
					UIGradient.Rotation = 90
					UIGradient.Parent = ParagraphSrc

					Title.Name = NguyenMinhNhat:ChiuMyLy();
					Title.Parent = ParagraphSrc
					Title.AnchorPoint = Vector2.new(0, 0.5)
					Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Title.BackgroundTransparency = 1.000
					Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Title.BorderSizePixel = 0
					Title.Position = UDim2.new(0, 5, 0, 14)
					Title.Size = UDim2.new(1, -10, 0, 15)
					Title.ZIndex = 12
					Title.Font = Enum.Font.GothamMedium
					Title.Text = ctx.Title
					Title.TextColor3 = Color3.fromRGB(255, 255, 255)
					Title.TextSize = 12.000
					Title.TextTransparency = 0.200
					Title.TextXAlignment = Enum.TextXAlignment.Left
					Label.RichText = true

					Content.Name = NguyenMinhNhat:ChiuMyLy();
					Content.Parent = ParagraphSrc
					Content.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Content.BackgroundTransparency = 1.000
					Content.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Content.BorderSizePixel = 0
					Content.Position = UDim2.new(0, 5, 0, 24)
					Content.Size = UDim2.new(1, -10, 1, -28)
					Content.ZIndex = 12
					Content.Font = Enum.Font.GothamMedium
					Content.Text = ctx.Content
					Content.TextColor3 = Color3.fromRGB(255, 255, 255)
					Content.TextSize = 10.000
					Content.TextTransparency = 0.400
					Content.TextXAlignment = Enum.TextXAlignment.Left
					Content.TextYAlignment = Enum.TextYAlignment.Top

					local Update = function()
						local SizeTitle = TextSv:GetTextSize(
							Title.Text,
							Title.TextSize,
							Title.Font,Vector2.new(math.huge,math.huge)
						);

						local SizeContent = TextSv:GetTextSize(
							Content.Text,
							Content.TextSize,
							Content.Font,
							Vector2.new(math.huge,math.huge)
						);

						TweenSv:Create(ParagraphSrc,TweenInfo.new(0.1),{
							Size = UDim2.new(1, -5, 0, (SizeTitle.Y + SizeContent.Y) + 17)
						}):Play();
					end;

					Update();

					function ctx:SetContent(a)
						Content.Text = a;

						Update();
					end;

					function ctx:SetTitle(a)
						Title.Text = a;

						Update();
					end;

					return ctx;
				end;

				----------------- KEYBIND -----------------
				function dick:AddKeybind(property)
					property = property or {};
					property.Title = property.Title or "Keybind";
					property.Default = property.Default or nil;
					property.Blacklist = property.Blacklist or {};
					property.Callback = property.Callback or function() end;

					local ToString = function(Key)
						if typeof(Key) == 'EnumItem' then
							return Key.Name;
						end;

						return tostring(Key or "NONE")
					end;

					local KeybindSrc = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local UIStroke = Instance.new("UIStroke")
					local UIGradient = Instance.new("UIGradient")
					local Label = Instance.new("TextLabel")
					local mv = Instance.new("Frame")
					local UICorner_2 = Instance.new("UICorner")
					local UIStroke_2 = Instance.new("UIStroke")
					local BindLabel = Instance.new("TextLabel")

					KeybindSrc.Name = NguyenMinhNhat:ChiuMyLy();
					KeybindSrc.Parent = SectionMainFrame;
					KeybindSrc.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					KeybindSrc.BackgroundTransparency = 0.150
					KeybindSrc.BorderColor3 = Color3.fromRGB(0, 0, 0)
					KeybindSrc.BorderSizePixel = 0
					KeybindSrc.ClipsDescendants = true
					KeybindSrc.Size = UDim2.new(1, -5, 0, 30)
					KeybindSrc.ZIndex = 11

					UICorner.CornerRadius = UDim.new(0, 2)
					UICorner.Parent = KeybindSrc

					UIStroke.Parent = KeybindSrc
					UIStroke.Color = Color3.fromRGB(172, 172, 172)
					UIStroke.Transparency = 0.890

					UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(243, 243, 243))}
					UIGradient.Rotation = 90
					UIGradient.Parent = KeybindSrc

					Label.Name = NguyenMinhNhat:ChiuMyLy();
					Label.Parent = KeybindSrc
					Label.AnchorPoint = Vector2.new(0, 0.5)
					Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Label.BackgroundTransparency = 1.000
					Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Label.BorderSizePixel = 0
					Label.Position = UDim2.new(0, 5, 0.5, 0)
					Label.Size = UDim2.new(1, -65, 0.5, 0)
					Label.ZIndex = 12
					Label.Font = Enum.Font.GothamMedium
					Label.Text = property.Title
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 12.000
					Label.TextTransparency = 0.200
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.RichText = true

					mv.Name = NguyenMinhNhat:ChiuMyLy();
					mv.Parent = KeybindSrc
					mv.AnchorPoint = Vector2.new(1, 0.5)
					mv.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					mv.BorderColor3 = Color3.fromRGB(0, 0, 0)
					mv.BorderSizePixel = 0
					mv.ClipsDescendants = true
					mv.Position = UDim2.new(1, -5, 0.5, 0)
					mv.Size = UDim2.new(0, 65, 0.600000024, 0)
					mv.ZIndex = 12

					UICorner_2.CornerRadius = UDim.new(0, 5)
					UICorner_2.Parent = mv

					UIStroke_2.Parent = mv
					UIStroke_2.Color = Color3.fromRGB(172, 172, 172)
					UIStroke_2.Transparency = 0.890

					BindLabel.Name = NguyenMinhNhat:ChiuMyLy();
					BindLabel.Parent = mv
					BindLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					BindLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					BindLabel.BackgroundTransparency = 1.000
					BindLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					BindLabel.BorderSizePixel = 0
					BindLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
					BindLabel.Size = UDim2.new(1, -10, 1, -10)
					BindLabel.ZIndex = 12
					BindLabel.Font = Enum.Font.GothamMedium
					BindLabel.Text = ToString(property.Default)
					BindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					BindLabel.TextSize = 10.000
					BindLabel.TextTransparency = 0.500
					BindLabel.TextXAlignment = Enum.TextXAlignment.Right

					local UpdateScale = function()
						local BindLabelScale = TextSv:GetTextSize(BindLabel.Text,BindLabel.TextSize,BindLabel.Font,Vector2.new(math.huge,math.huge));

						TweenSv:Create(mv,TweenInfo.new(0.1),{
							Size = UDim2.new(0, BindLabelScale.X + 10, 0.6, 0)
						}):Play();
					end;

					UpdateScale();

					local Button = NguyenMinhNhat:NewInput(KeybindSrc);
					local IsBinding = false;

					Button.MouseButton1Click:Connect(function()
						if IsBinding then return; end;
						IsBinding = true;

						BindLabel.Text = "...";

						UpdateScale();

						local Selected = nil;
						while not Selected do
							local Key = UserInputSv.InputBegan:Wait();

							if Key.KeyCode ~= Enum.KeyCode.Unknown and not table.find(property.Blacklist , ToString(Key.KeyCode)) and not table.find(property.Blacklist , Key.KeyCode) then
								Selected = Key.KeyCode;
							end;
						end;

						property.Default = Selected;

						BindLabel.Text = ToString(Selected);

						UpdateScale();

						IsBinding = false;

						property.Callback(Selected,property);
					end)

					function property:SetValue(new)
						property.Default = new;

						BindLabel.Text = ToString(new);

						UpdateScale();

						property.Callback(new,true);
					end;

					function property:Destroy()
						KeybindSrc:Destroy();
					end;

					return property;
				end;

				-------------- Textbox -------------
				function dick:AddTextbox(property)
					property = property or {};

					property.Title = property.Title or "Textbox";
					property.Placeholder = property.Placeholder or "   ";
					property.Default = property.Default or "";
					property.Callback = property.Callback or function() end;
					property.Numeric = property.Numeric or false;
					property.Finished = property.Finished or false;

					local TextboxSrc = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local UIStroke = Instance.new("UIStroke")
					local UIGradient = Instance.new("UIGradient")
					local Label = Instance.new("TextLabel")
					local mv = Instance.new("Frame")
					local UICorner_2 = Instance.new("UICorner")
					local UIStroke_2 = Instance.new("UIStroke")
					local InputBox = Instance.new("TextBox")

					TextboxSrc.Name = NguyenMinhNhat:ChiuMyLy();
					TextboxSrc.Parent = SectionMainFrame
					TextboxSrc.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					TextboxSrc.BackgroundTransparency = 0.150
					TextboxSrc.BorderColor3 = Color3.fromRGB(0, 0, 0)
					TextboxSrc.BorderSizePixel = 0
					TextboxSrc.ClipsDescendants = true
					TextboxSrc.Size = UDim2.new(1, -5, 0, 30)
					TextboxSrc.ZIndex = 11

					UICorner.CornerRadius = UDim.new(0, 2)
					UICorner.Parent = TextboxSrc

					UIStroke.Parent = TextboxSrc
					UIStroke.Color = Color3.fromRGB(172, 172, 172)
					UIStroke.Transparency = 0.890

					UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(243, 243, 243))}
					UIGradient.Rotation = 90
					UIGradient.Parent = TextboxSrc

					Label.Name = NguyenMinhNhat:ChiuMyLy();
					Label.Parent = TextboxSrc
					Label.AnchorPoint = Vector2.new(0, 0.5)
					Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Label.BackgroundTransparency = 1.000
					Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Label.BorderSizePixel = 0
					Label.Position = UDim2.new(0, 5, 0.5, 0)
					Label.Size = UDim2.new(1, -65, 0.5, 0)
					Label.ZIndex = 12
					Label.Font = Enum.Font.GothamMedium
					Label.Text = property.Title
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 12.000
					Label.TextTransparency = 0.200
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.RichText = true

					mv.Name = NguyenMinhNhat:ChiuMyLy();
					mv.Parent = TextboxSrc
					mv.AnchorPoint = Vector2.new(1, 0.5)
					mv.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					mv.BorderColor3 = Color3.fromRGB(0, 0, 0)
					mv.BorderSizePixel = 0
					mv.ClipsDescendants = true
					mv.Position = UDim2.new(1, -5, 0.5, 0)
					mv.Size = UDim2.new(0, 90, 0.600000024, 0)
					mv.ZIndex = 12

					UICorner_2.CornerRadius = UDim.new(0, 5)
					UICorner_2.Parent = mv

					UIStroke_2.Parent = mv
					UIStroke_2.Color = Color3.fromRGB(172, 172, 172)
					UIStroke_2.Transparency = 0.890

					InputBox.Name = NguyenMinhNhat:ChiuMyLy();
					InputBox.Parent = mv
					InputBox.AnchorPoint = Vector2.new(0, 0.5)
					InputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					InputBox.BackgroundTransparency = 1.000
					InputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
					InputBox.BorderSizePixel = 0
					InputBox.Position = UDim2.new(0, 0, 0.5, 0)
					InputBox.Size = UDim2.new(1, 0, 0.600000024, 0)
					InputBox.ZIndex = 19
					InputBox.ClearTextOnFocus = false
					InputBox.Font = Enum.Font.GothamMedium
					InputBox.PlaceholderText = property.Placeholder
					InputBox.Text = tostring(property.Default)
					InputBox.TextColor3 = Color3.fromRGB(238, 238, 238)
					InputBox.TextSize = 10.000
					InputBox.TextTransparency = 0.500

					local updateScale = function()
						local scale = TextSv:GetTextSize(InputBox.Text,InputBox.TextSize,InputBox.Font,Vector2.new(math.huge,math.huge));
						local Base = TextSv:GetTextSize(InputBox.PlaceholderText,InputBox.TextSize,InputBox.Font,Vector2.new(math.huge,math.huge));
						local max = math.abs(TextboxSrc.AbsoluteSize.X - 95);

						TweenSv:Create(mv,TweenInfo.new(0.1),{
							Size = UDim2.new(0, math.clamp(scale.X , Base.X , math.max(max , Base.X) + 10) + 9, 0.6, 0)
						}):Play();
					end;

					updateScale();

					local parse = function()
						if property.Numeric then
							InputBox.Text = string.gsub(InputBox.Text, '[^0-9.]', '')

							if tonumber(InputBox.Text) then
								property.Callback(tonumber(InputBox.Text));
							end;


							return;
						end;

						property.Callback(InputBox.Text,property)
					end;

					if property.Finished then
						InputBox.FocusLost:Connect(parse);
					end;

					InputBox:GetPropertyChangedSignal('Text'):Connect(function()
						updateScale();
						if not property.Finished then
							parse()
						end
					end)

					function property:SetValue(new)
						property.Default = new;
						InputBox.Text = tostring(new);

						property.Callback(new,true);
					end;

					function property:Destroy()
						TextboxSrc:Destroy();
					end;

					return property;
				end;

				----------- Slider -----------
				function dick:AddSlider(property)
					property = property or {};

					property.Title = property.Title or "Slider";
					property.Min = property.Min or 0;
					property.Max = property.Max or 100;
					property.Rounding = property.Rounding or 0;
					property.Default = property.Default or property.Min;
					property.Type = property.Type or "%";
					property.Callback = property.Callback or function() end;

					local SliderSrc = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local UIStroke = Instance.new("UIStroke")
					local UIGradient = Instance.new("UIGradient")
					local Label = Instance.new("TextLabel")
					local ValueLabel = Instance.new("TextLabel")
					local mv = Instance.new("Frame")
					local UIStroke_2 = Instance.new("UIStroke")
					local UICorner_2 = Instance.new("UICorner")
					local move = Instance.new("Frame")
					local UICorner_3 = Instance.new("UICorner")
					local UIGradient_2 = Instance.new("UIGradient")

					SliderSrc.Name = NguyenMinhNhat:ChiuMyLy();
					SliderSrc.Parent = SectionMainFrame
					SliderSrc.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					SliderSrc.BackgroundTransparency = 0.150
					SliderSrc.BorderColor3 = Color3.fromRGB(0, 0, 0)
					SliderSrc.BorderSizePixel = 0
					SliderSrc.ClipsDescendants = true
					SliderSrc.Size = UDim2.new(1, -5, 0, 40)
					SliderSrc.ZIndex = 11

					UICorner.CornerRadius = UDim.new(0, 2)
					UICorner.Parent = SliderSrc

					UIStroke.Parent = SliderSrc
					UIStroke.Color = Color3.fromRGB(172, 172, 172)
					UIStroke.Transparency = 0.890

					UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(243, 243, 243))}
					UIGradient.Rotation = 90
					UIGradient.Parent = SliderSrc

					Label.Name = NguyenMinhNhat:ChiuMyLy();
					Label.Parent = SliderSrc
					Label.AnchorPoint = Vector2.new(0, 0.5)
					Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Label.BackgroundTransparency = 1.000
					Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Label.BorderSizePixel = 0
					Label.Position = UDim2.new(0, 5, 0, 14)
					Label.Size = UDim2.new(1, -65, 0, 15)
					Label.ZIndex = 12
					Label.Font = Enum.Font.GothamMedium
					Label.Text = property.Title
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 12.000
					Label.TextTransparency = 0.200
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.RichText = true

					ValueLabel.Name = NguyenMinhNhat:ChiuMyLy();
					ValueLabel.Parent = SliderSrc
					ValueLabel.AnchorPoint = Vector2.new(1, 0.5)
					ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ValueLabel.BackgroundTransparency = 1.000
					ValueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					ValueLabel.BorderSizePixel = 0
					ValueLabel.Position = UDim2.new(1, -5, 0, 14)
					ValueLabel.Size = UDim2.new(1, -65, 0, 15)
					ValueLabel.ZIndex = 12
					ValueLabel.Font = Enum.Font.GothamMedium
					ValueLabel.Text = tostring(property.Default)..tostring(property.Type)
					ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					ValueLabel.TextSize = 10.000
					ValueLabel.TextTransparency = 0.400
					ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

					mv.Name = NguyenMinhNhat:ChiuMyLy();
					mv.Parent = SliderSrc
					mv.AnchorPoint = Vector2.new(0, 1)
					mv.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					mv.BorderColor3 = Color3.fromRGB(0, 0, 0)
					mv.BorderSizePixel = 0
					mv.ClipsDescendants = true
					mv.Position = UDim2.new(0, 5, 1, -5)
					mv.Size = UDim2.new(1, -10, 0, 10)
					mv.ZIndex = 22

					UIStroke_2.Parent = mv
					UIStroke_2.Color = Color3.fromRGB(172, 172, 172)
					UIStroke_2.Transparency = 0.890

					UICorner_2.CornerRadius = UDim.new(1, 0)
					UICorner_2.Parent = mv

					move.Name = NguyenMinhNhat:ChiuMyLy();
					move.Parent = mv
					move.AnchorPoint = Vector2.new(0, 0.5)
					move.BackgroundColor3 = Color3.fromRGB(0, 255, 238)
					move.BorderColor3 = Color3.fromRGB(0, 0, 0)
					move.BorderSizePixel = 0
					move.Position = UDim2.new(0, 0, 0.5, 0)
					move.Size = UDim2.new(0.100000001, 0, 1, 0)
					move.ZIndex = 23

					UICorner_3.CornerRadius = UDim.new(1, 0)
					UICorner_3.Parent = move

					UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.81, Color3.fromRGB(195, 195, 195)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(186, 186, 186))}
					UIGradient_2.Rotation = 90
					UIGradient_2.Parent = move

					TweenSv:Create(move , TweenInfo.new(0.1),{
						Size = UDim2.new((property.Default) / (property.Max), 0, 1, 0)
					}):Play();

					local IsHold = false;

					local function update(Input)
						local SizeScale = math.clamp((((Input.Position.X) - mv.AbsolutePosition.X) / mv.AbsoluteSize.X), 0, 1);
						local Main = ((property.Max - property.Min) * SizeScale) + property.Min;
						local Value = NguyenMinhNhat:Rounding(Main,property.Rounding);
						local PositionX = UDim2.fromScale(SizeScale, 1);
						local normalized = (Value - property.Min) / (property.Max - property.Min);

						TweenSv:Create(move , TweenInfo.new(0.1),{
							Size = UDim2.new(normalized, 0, 1, 0)
						}):Play();

						ValueLabel.Text = tostring(Value)..tostring(property.Type)

						property.Callback(Value,property)
					end;

					mv.InputBegan:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							IsHold = true
							update(Input)
						end
					end)

					mv.InputEnded:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							IsHold = false
						end
					end)

					UserInputSv.InputChanged:Connect(function(Input)
						if IsHold then
							if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)  then
								update(Input)
							end
						end
					end);

					function property:SetValue(new)
						property.Default = new;
						ValueLabel.Text = tostring(new)..tostring(property.Type)

						property.Callback(new,true);
					end;

					function property:Destroy()
						SliderSrc:Destroy();
					end;

					return property;
				end;

				------------- Dropdown -------------
				function dick:AddDropdown(property)
					property = property or {};

					property.Title = property.Title or "Dropdown";
					property.Values = property.Values or {};
					property.Default = property.Default or nil;
					property.Multi = property.Multi or false;
					property.Callback = property.Callback or function() end;
					property.SearchBar = property.SearchBar or false;
					
					local IsArray = function(a)
						for i,v in ipairs(a) do
							return false;
						end;
						return true;
					end;

					local ConcatFunction = function(val)
						if typeof(val) == 'table' then
							local src = {};

							local isArray = IsArray(val);

							if isArray then
								for i,v in next , val do
									if v then
										table.insert(src,tostring(i));
									end;
								end;
							else
								for i,v in next , val do
									table.insert(src,tostring(v));
								end;
							end;

							return table.concat(src,' , ');
						end;

						return tostring(val or "NONE");
					end;

					local DropdownSrc = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local UIStroke = Instance.new("UIStroke")
					local UIGradient = Instance.new("UIGradient")
					local Label = Instance.new("TextLabel")
					local mv = Instance.new("Frame")
					local UICorner_2 = Instance.new("UICorner")
					local UIStroke_2 = Instance.new("UIStroke")
					local ValueLabel = Instance.new("TextLabel")

					DropdownSrc.Name = NguyenMinhNhat:ChiuMyLy();
					DropdownSrc.Parent = SectionMainFrame;
					DropdownSrc.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					DropdownSrc.BackgroundTransparency = 0.150
					DropdownSrc.BorderColor3 = Color3.fromRGB(0, 0, 0)
					DropdownSrc.BorderSizePixel = 0
					DropdownSrc.ClipsDescendants = true
					DropdownSrc.Size = UDim2.new(1, -5, 0, 30)
					DropdownSrc.ZIndex = 11

					UICorner.CornerRadius = UDim.new(0, 2)
					UICorner.Parent = DropdownSrc

					UIStroke.Parent = DropdownSrc
					UIStroke.Color = Color3.fromRGB(172, 172, 172)
					UIStroke.Transparency = 0.890

					UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(243, 243, 243))}
					UIGradient.Rotation = 90
					UIGradient.Parent = DropdownSrc

					Label.Name = NguyenMinhNhat:ChiuMyLy();
					Label.Parent = DropdownSrc
					Label.AnchorPoint = Vector2.new(0, 0.5)
					Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Label.BackgroundTransparency = 1.000
					Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Label.BorderSizePixel = 0
					Label.Position = UDim2.new(0, 5, 0.5, 0)
					Label.Size = UDim2.new(1, -65, 0.5, 0)
					Label.ZIndex = 12
					Label.Font = Enum.Font.GothamMedium
					Label.Text = property.Title
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 12.000
					Label.TextTransparency = 0.200
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.RichText = true

					mv.Name = NguyenMinhNhat:ChiuMyLy();
					mv.Parent = DropdownSrc
					mv.AnchorPoint = Vector2.new(1, 0.5)
					mv.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					mv.BorderColor3 = Color3.fromRGB(0, 0, 0)
					mv.BorderSizePixel = 0
					mv.ClipsDescendants = true
					mv.Position = UDim2.new(1, -5, 0.5, 0)
					mv.Size = UDim2.new(0, 15, 0.600000024, 0)
					mv.ZIndex = 12

					UICorner_2.CornerRadius = UDim.new(0, 5)
					UICorner_2.Parent = mv

					UIStroke_2.Parent = mv
					UIStroke_2.Color = Color3.fromRGB(172, 172, 172)
					UIStroke_2.Transparency = 0.890

					ValueLabel.Name = NguyenMinhNhat:ChiuMyLy();
					ValueLabel.Parent = mv
					ValueLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ValueLabel.BackgroundTransparency = 1.000
					ValueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					ValueLabel.BorderSizePixel = 0
					ValueLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
					ValueLabel.Size = UDim2.new(1, -10, 1, -10)
					ValueLabel.ZIndex = 12
					ValueLabel.Font = Enum.Font.GothamMedium
					ValueLabel.Text = tostring(ConcatFunction(property.Default) or "NONE");
					ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					ValueLabel.TextSize = 10.000
					ValueLabel.TextTransparency = 0.500
					ValueLabel.RichText = true

					local updateScale = function()
						local scale = TextSv:GetTextSize(ValueLabel.Text,ValueLabel.TextSize,ValueLabel.Font,Vector2.new(math.huge,math.huge));

						TweenSv:Create(mv,TweenInfo.new(0.1),{
							Size = UDim2.new(0, scale.X + 10, 0.600000024, 0)
						}):Play();
					end;

					updateScale();

					local Button = NguyenMinhNhat:NewInput(DropdownSrc);
					local UpdateFrame = function(arg : any | {any})
						property.Default = arg;
						ValueLabel.Text = ConcatFunction(arg);

						task.spawn(function()
							property.Callback(arg,property);
						end);

						updateScale();
					end;

					Button.MouseButton1Click:Connect(function()
						DropdownSyu:Close();
						DropdownSyu:Init(property.Values,property.Default,property.Multi,mv,UpdateFrame,property.SearchBar);
					end);

					function property:SetValues(a)
						property.Values = a;
					end;

					function property:SetDefault(f)
						property.Default = f;
					end;

					function property:Destroy()
						DropdownSrc:Destroy();
					end;

					return property;
				end;
			end;

			local ToggleVal = function(val,start)
				if val then
					SectionMainFrame.Visible = true;

					TweenSv:Create(SectionMainFrame,TweenInfo.new(0.35 , Enum.EasingStyle.Quint , Enum.EasingDirection.InOut),{
						Position = UDim2.fromScale(0.5,0.5)
					}):Play();

					TweenSv:Create(SectionInput,TweenInfo.new(0.1),{
						BackgroundTransparency = 0.200
					}):Play();

					TweenSv:Create(Label,TweenInfo.new(0.1),{
						TextTransparency = 0.200
					}):Play();
				else

					TweenSv:Create(SectionMainFrame,TweenInfo.new(0.35 , Enum.EasingStyle.Quint , Enum.EasingDirection.InOut),{
						Position = start
					}):Play();

					TweenSv:Create(SectionInput,TweenInfo.new(0.1),{
						BackgroundTransparency = 0.45
					}):Play();

					TweenSv:Create(Label,TweenInfo.new(0.1),{
						TextTransparency = 0.35
					}):Play();
				end;
			end;

			local SectionId = ToggleVal;

			if not obj.SelectedSeciton then
				obj.SelectedSeciton = ToggleVal;

				ToggleVal(true);
			else
				ToggleVal(false,UDim2.fromScale(1.5,0.5));
			end;

			table.insert(obj.Cache , SectionId)

			local MyId = #obj.Cache;
			local Button = NguyenMinhNhat:NewInput(SectionInput);

			Button.MouseButton1Click:Connect(function()
				local FoundSelected = nil;
				local Selected = obj.SelectedSeciton;

				for i,v in next , obj.Cache do
					if v == FoundSelected then
						FoundSelected = v;
					end;

					if v == SectionId then
						obj.SelectedSeciton = v;
						v(true);
					else
						if i < MyId then
							v(false,UDim2.fromScale(-1.5,0.5));
						else
							v(false,UDim2.fromScale(1.5,0.5));

						end;
					end;
				end;
			end);

			return dick;
		end;

		local ToggleVal = function(val)
			if val then
				TabBlock.Visible = true

				TweenSv:Create(TabButton,TweenInfo.new(0.1),{
					BackgroundColor3 = Color3.fromRGB(61, 149, 204)
				}):Play();

				TweenSv:Create(Icon,TweenInfo.new(0.4 ),{
					ImageColor3 = Color3.fromRGB(0, 255, 238),
				}):Play();

				TweenSv:Create(Icon,TweenInfo.new(0.4 , Enum.EasingStyle.Back , Enum.EasingDirection.InOut),{
					Size = UDim2.new(0.75, 0, 0.75, 0),
					Position = UDim2.new(0,4,0.5,0)
				}):Play();

				TweenSv:Create(PText,TweenInfo.new(0.1),{
					TextTransparency = 0.1
				}):Play();
			else
				TabBlock.Visible = false

				TweenSv:Create(PText,TweenInfo.new(0.1),{
					TextTransparency = 0.5
				}):Play();

				TweenSv:Create(TabButton,TweenInfo.new(0.1),{
					BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				}):Play();

				TweenSv:Create(Icon,TweenInfo.new(0.4),{
					ImageColor3 = Color3.fromRGB(243, 243, 243),
					Size = UDim2.new(0.699999988, 0, 0.699999988, 0),
					Position = UDim2.new(0,5,0.5,0)
				}):Play();
			end;
		end;

		local MyVal = ToggleVal;

		if not self.SelectedTab then
			self.SelectedTab = MyVal;
			ToggleVal(true);
		else
			ToggleVal(false);
		end;

		table.insert(self.Cache.Tab,MyVal)

		local Button = NguyenMinhNhat:NewInput(TabButton);

		Button.MouseButton1Click:Connect(function()
			for i,v in next , self.Cache.Tab do
				if v == MyVal then
					v(true);
				else
					v(false);
				end;
			end;
		end)

		return obj;
	end;

	-----------------------------------------------
	local dragToggle = nil;
	local dragSpeed = 0.1;
	local dragStart = nil;
	local startPos = nil;

	local function updateInput(input)
		local delta = input.Position - dragStart;
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y);

		game:GetService('TweenService'):Create(WindowFrame, TweenInfo.new(dragSpeed), {Position = position}):Play()
	end;

	Headers.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true
			dragStart = input.Position
			startPos = WindowFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false;
				end;
			end)
		end;
	end)

	--------------------- RESIZE ---------------------

	local Resize = Instance.new("TextButton")
	local IsHold = false;

	Resize.Name = NguyenMinhNhat:ChiuMyLy();
	Resize.Parent = WindowFrame
	Resize.AnchorPoint = Vector2.new(0.5, 0.5)
	Resize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Resize.BackgroundTransparency = 1.000
	Resize.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Resize.BorderSizePixel = 0
	Resize.Position = UDim2.new(1, 0, 1, 0)
	Resize.Rotation = 0.010
	Resize.Size = UDim2.new(0.075000003, 0, 0.075000003, 0)
	Resize.SizeConstraint = Enum.SizeConstraint.RelativeYY
	Resize.ZIndex = 100
	Resize.Font = Enum.Font.SourceSans
	Resize.Text = ""
	Resize.TextColor3 = Color3.fromRGB(0, 0, 0)
	Resize.TextSize = 14.000

	Resize.InputBegan:Connect(function(std)
		if std.UserInputType == Enum.UserInputType.MouseButton1 or std.UserInputType == Enum.UserInputType.Touch then
			IsHold = true
			if UserInputSv.TouchEnabled then
				Resize.Size = UDim2.new(0.15000003, 85, 0.15000003, 85)
			end
		end
	end)

	Resize.InputEnded:Connect(function(std)
		if std.UserInputType == Enum.UserInputType.MouseButton1 or std.UserInputType == Enum.UserInputType.Touch then
			IsHold = false
			Resize.Size = UDim2.new(0.075000003, 0, 0.075000003, 0)
		end
	end)

	UserInputSv.InputChanged:Connect(function(input)
		if IsHold and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			if self.Toggle then
				local pios = input.Position;
				local x = (pios.X - WindowFrame.AbsolutePosition.X) 

				local y = (pios.Y - WindowFrame.AbsolutePosition.Y) 

				if x < 390 then x = 390 end
				if y < 240 then y = 240 end

				local Offset = UDim2.new(0,x,0,y)
				local plus = UDim2.fromOffset(-(WindowFrame.AbsoluteSize.X - x) / 2, -(WindowFrame.AbsoluteSize.Y - y) / 2);

				self.Scale = Offset

				TweenSv:Create(WindowFrame , TweenInfo.new(0.05),{
					Size = Offset,
					Position = WindowFrame.Position + plus,
				}):Play();
			end;
		end;

		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				updateInput(input);
			end;
		end;
	end);


	local GWindow = Instance.new("Frame")
	local MinButtonT = Instance.new("ImageButton")

	if UserInputSv.TouchEnabled then
		local UICorner = Instance.new("UICorner")
		local DropShadow = Instance.new("ImageLabel")
		local Headers = Instance.new("Frame")
		local WindowText = Instance.new("TextLabel")
		local Frame = Instance.new("Frame")
		local UIListLayout = Instance.new("UIListLayout")
		local HeadLine = Instance.new("Frame")

		GWindow.Name = NguyenMinhNhat:ChiuMyLy();
		GWindow.Parent = SpyderXLib
		GWindow.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		GWindow.BackgroundTransparency = 0.040
		GWindow.BorderColor3 = Color3.fromRGB(0, 0, 0)
		GWindow.BorderSizePixel = 0
		GWindow.Position = UDim2.new(0.2, 0, 0.2, 0)
		GWindow.Size = UDim2.new(0, 0, 0, 0) -- UDim2.new(0, 135, 0, 34)
		GWindow.ZIndex = 154
		GWindow.AnchorPoint = Vector2.new(0.5,0.5)
		GWindow.ClipsDescendants = true

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = GWindow

		DropShadow.Name = NguyenMinhNhat:ChiuMyLy();
		DropShadow.Parent = GWindow
		DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
		DropShadow.BackgroundTransparency = 1.000
		DropShadow.BorderSizePixel = 0
		DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		DropShadow.Rotation = 0.010
		DropShadow.Size = UDim2.new(1, 47, 1, 47)
		DropShadow.ZIndex = 153
		DropShadow.Image = (NguyenMinhNhat.EnableIcon and "rbxassetid://6015897843") or "";
		DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		DropShadow.ImageTransparency = 1
		DropShadow.ScaleType = Enum.ScaleType.Slice
		DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
		DropShadow.Rotation = 0.001;
		DropShadow.Active = true

		Headers.Name = NguyenMinhNhat:ChiuMyLy();
		Headers.Parent = GWindow
		Headers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Headers.BackgroundTransparency = 1.000
		Headers.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Headers.BorderSizePixel = 0
		Headers.Size = UDim2.new(1, 0, 0, 23)
		Headers.ZIndex = 155

		WindowText.Name = NguyenMinhNhat:ChiuMyLy();
		WindowText.Parent = Headers
		WindowText.AnchorPoint = Vector2.new(0, 0.5)
		WindowText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		WindowText.BackgroundTransparency = 1.000
		WindowText.BorderColor3 = Color3.fromRGB(0, 0, 0)
		WindowText.BorderSizePixel = 0
		WindowText.Position = UDim2.new(0, 4, 0.5, 0)
		WindowText.Size = UDim2.new(1, -45, 0.5, 0)
		WindowText.ZIndex = 156
		WindowText.Font = Enum.Font.GothamMedium
		WindowText.Text = self.Title
		WindowText.TextColor3 = Color3.fromRGB(223, 223, 223)
		WindowText.TextSize = 12.000
		WindowText.TextXAlignment = Enum.TextXAlignment.Left

		Frame.Parent = Headers
		Frame.AnchorPoint = Vector2.new(1, 0.5)
		Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame.BackgroundTransparency = 1.000
		Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Position = UDim2.new(1, -4, 0.5, 0)
		Frame.Size = UDim2.new(0.699999988, 0, 0.699999988, 0)
		Frame.ZIndex = 4

		MinButtonT.Name = NguyenMinhNhat:ChiuMyLy();
		MinButtonT.Parent = Frame
		MinButtonT.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		MinButtonT.BackgroundTransparency = 1.000
		MinButtonT.BorderColor3 = Color3.fromRGB(0, 0, 0)
		MinButtonT.BorderSizePixel = 0
		MinButtonT.Size = UDim2.new(1, 0, 1, 0)
		MinButtonT.SizeConstraint = Enum.SizeConstraint.RelativeYY
		MinButtonT.ZIndex = 250

		if NguyenMinhNhat.EnableIcon then
			MinButtonT.Image = "rbxassetid://9886659276"
		else
			NguyenMinhNhat.CreateEmuIcon(MinButtonT,'-')
		end

		UIListLayout.Parent = Frame
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		UIListLayout.Padding = UDim.new(0, 5)

		HeadLine.Name = NguyenMinhNhat:ChiuMyLy();
		HeadLine.Parent = Headers
		HeadLine.AnchorPoint = Vector2.new(0, 1)
		HeadLine.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
		HeadLine.BackgroundTransparency = 0.050
		HeadLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
		HeadLine.BorderSizePixel = 0
		HeadLine.Position = UDim2.new(0, 0, 1, 0)
		HeadLine.Size = UDim2.new(1, 0, 0, 1)
		HeadLine.ZIndex = 156

		local dragToggle = nil;
		local dragSpeed = 0.1;
		local dragStart = nil;
		local startPos = nil;

		local function updateInput(input)
			local delta = input.Position - dragStart;
			local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y);

			game:GetService('TweenService'):Create(GWindow, TweenInfo.new(dragSpeed), {Position = position}):Play()
		end;

		GWindow.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
				dragToggle = true
				dragStart = input.Position
				startPos = GWindow.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragToggle = false;
					end;
				end)
			end;
		end);

		UserInputSv.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				if dragToggle then
					updateInput(input);
				end;
			end;
		end);

	end;

	local ToggleWindow = function()
		self.Toggle = not self.Toggle;

		if self.Toggle then
			TweenSv:Create(WindowFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
				Size = self.Scale
			}):Play();

			TweenSv:Create(DropShadow,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
				ImageTransparency = 0.5
			}):Play();

			if GWindow then
				TweenSv:Create(GWindow,TweenInfo.new(0.75,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
					Size = UDim2.new(0, 0, 0, 0)
				}):Play();
			end
		else
			if GWindow then
				TweenSv:Create(GWindow,TweenInfo.new(0.75,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
					Size = UDim2.new(0, 135, 0, 34)
				}):Play();
			end

			TweenSv:Create(DropShadow,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
				ImageTransparency = 1
			}):Play();

			TweenSv:Create(WindowFrame,TweenInfo.new(0.75,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
				Size = UDim2.new(0,0,0,0)
			}):Play()
		end;	
	end;

	UserInputSv.InputBegan:Connect(function(Input : InputObject)
		if Input.KeyCode == self.Keybind then
			ToggleWindow()
		end;
	end);

	MinButton.MouseButton1Click:Connect(ToggleWindow);

	MinButtonT.MouseButton1Click:Connect(ToggleWindow);

	return self;
end;

return NguyenMinhNhat;
