	global unInst

	struct hkxImporter
	(
	-------------------------------------------------------
		-- General
	-- 		unInst,
			dnHkxList = undefined,
			dnAnnotationList = undefined,
			hkxPath = undefined,
			allChildren = #(),
			btnState = 0,
			RootSrc,
			switch = 0,
			ntp1,
	-------------------------------------------------------
	-- Human
			pHuman,
			userprops_human = #(),
	-------------------------------------------------------
	-- Ghoul
			pGhoul,
			userprops_ghoul = #(),
	-------------------------------------------------------
	-- Supermutant
			pSuperMutant,	
			userprops_supermutant = #(),
	-------------------------------------------------------
	-- Fallout 76
			pF76,
			userprops_fallout76 = #(),
			
	-------------------------------------------------------
	-- Buttons
			dnRadioBtnOne,
			dnRadioBtnTwo,
			dnRadioBtnThree,
			dnRadioBtnFour,
			dnBtnRun,
			dnBtnBrowse,
			
		fn formatProps sender option:#All=
		(
			clearListener()
			if classOf sender==dotNetObject or classOf sender==dotNetClass then
			(
				if option == #All or option==#constructor do
				(
					format "\nConstructors****************************:\n"
					dotNet.showConstructors sender
				)
				
				if option == #All or option==#properties do
				(
					format "\nProperties****************************:\n"
					showProperties sender
				)
				
				if option == #All or option==#methods do
				(
					format "\nMethods****************************:\n"
					showMethods sender
				)
				
				if option == #All or option==#events do
				(
					format "\nEvents****************************:\n"
					showEvents sender
				)
			) else (format "Not a dotNetObject or dotNetClass!: %\n" sender)
		),
		
		maxBackColor=colorMan.getColor #background,
		
		fn dnColor c:[0,0,0] a:255 =((dotNetClass "system.drawing.color").FromArgb a c.x c.y c.z),
		fn dnRec p:[0,0] s:[10,10]=(dotNetObject "system.drawing.rectangle" p.x p.y s.x s.y), 
		fn dnSize s:[10,10]=(dotNetObject "system.drawing.size" s.x s.y),
		
		fn resetBipFile = (
	-- 		destroyDialog unInst
			loadMaxFile (maxFilePath + maxFileName) quiet:true
	-- 		fileIn(getThisScriptFilename()) 
		),
		
		fn resetVar = (
			
		),
		
		fn runCheck = (
			if $Root_source == undefined or $Root_human == undefined or \
				$Root_ghoul == undefined or  $Root_supermutant == undefined or \ 
				$Root_fallout76 == undefined then (
					print "Error in Bip-File. Performing Bip-File reset."
					resetBipFile()
			) else (
					print "Bip-File is valid."
			)
		),
		
		fn hkxreano exe_path arg_array:undefined as_string:false = (
	        local process = dotNetObject "System.Diagnostics.Process"

	        process.StartInfo.UseShellExecute = false
	        process.StartInfo.RedirectStandardOutput = true
	        process.StartInfo.RedirectStandardError = true
	        process.StartInfo.FileName = exe_path
	        process.StartInfo.Arguments = ""
	        
	        if arg_array != undefined then
	        (
	        	for arg in arg_array do (process.StartInfo.Arguments += (" " + arg as string))
	        )

	        process.Start()
	        process.WaitForExit()

	        local _output = process.StandardOutput.ReadToEnd()
	        local _error = process.StandardError.ReadToEnd()

	        process.Close()
	        process.Dispose()
	        
	        if _error == "" then
	        (
	            if as_string then return (trimRight _output "\r\n")
	            else return (filterString _output "\r\n" splitEmptyTokens:false)
	        )
	        else
	        (
	            if as_string then return (trimRight _error "\r\n")
	            else return (filterString _error "\r\n" splitEmptyTokens:false)
	        )
	    ),
		
		fn createNoteTrack = (
			
			if ntp1 == undefined then (
				ntp1 = NoteTrack "Notes"
				addNoteTrack $Root_Source ntp1
			) 
			
			for i = 1 to dnAnnotationList.items.count do (
				reformatTime = substring (dnAnnotationList.items.item[i-1].subitems.item[1].text) (1) (dnAnnotationList.items.item[i-1].subitems.item[1].text.count-1) as integer
				addNewNoteKey ntp1.keys reformatTime
			)
			n = getNoteTrack $Root_Source 1
			nk = n.keys
			for i = 1 to nk.count do (
				nk[i].value = (dnAnnotationList.items.item[i-1].subitems.item[0].text)
			)
		),
		
		fn initXMLPanel str = (
				liAno = #()
				timeKey = #()
				valueKey = #()
			
				EnvironmentAno = dotNetClass "System.Environment"
				tmpAno = EnvironmentAno.GetEnvironmentVariable "temp"
				AnoFile = tmpAno + "\annotations.xml"
				
					fs = openFile AnoFile
					while not eof fs do(
					l = readline fs
					append liAno l
			)
			close fs
	-- 		for i=1 to liAno.count/2 do (
	-- 			li=dotNetObject "System.Windows.Forms.ListViewItem" liAno[i]
	-- 			hkxImporter.dnAnnotationList.items.add li
	-- 		)
			
			for i=1 to liAno.count-1 do (
				list=dotNetObject "System.Windows.Forms.ListViewItem" liAno[i]
				
					if i < (liAno.count/2)+1 then (
					intTmp = (liAno.count/2)+i
					strToFloat = liAno[intTmp] as float
					strToFloat = strToFloat*30
					FloatToInt = strToFloat as integer
					calcStr = FloatToInt as string	
					append timeKey FloatToInt
					append valueKey liAno[i]
					calcStr = calcStr+"f"

					list.subitems.add calcStr
					hkxImporter.dnAnnotationList.items.add list
					)
			)
			createNoteTrack()
		),
			
		fn AnimTransfer catparentnode srcRoot camfile quiet:true delsrc:false StartTime:animationRange.start EndTime:animationRange.end layername:"" = (		
			
			if switch == 4 then (
				ikObj = $Bip_RLeg_Thigh
				ikObj.controller.limb.layerIKFKRatio = 0
				ikObj = $Bip_LLeg_Thigh
				ikObj.controller.limb.layerIKFKRatio = 0
			)
			rCaptureAnim.openDialog quiet:quiet;
			
			rCaptureAnim.spnStartTime.value = StartTime;
			rCaptureAnim.spnEndTime.value = EndTime;
			
			rCaptureAnim.catparent = catparentnode;
			rCaptureAnim.addCATRigToListView();
			
			rCaptureAnim.source_nodes = #(srcRoot);
			rCaptureAnim.updateSource();
			
			if layername.count > 0 then
				rCaptureAnim.targetLayerName = layername;
			else if srcRoot != undefined then
				rCaptureAnim.targetLayerName = srcRoot.name;
				
			if quiet then
			(
				try(
					rCaptureAnim.chkDeleteSource.checked = delsrc;	
					
					rCaptureAnim.targetLayerInfo = undefined;		

					if camfile != undefined and (doesFileExist camfile) then
					(
						rCaptureAnim.loadMapping camfile;
						rCaptureAnim.DoCapture();
					)else(
						DestroyDialog rCaptureAnim;	
						return false;
					)
					
				)catch(
					DestroyDialog rCaptureAnim;	
					return false;
				)
				DestroyDialog rCaptureAnim;	
				
				return true;
			)
			
		),
		
		fn createHKOconfig str = (
			
			EnvironmentHKO = dotNetClass "System.Environment"
			tmpHKO = EnvironmentHKO.GetEnvironmentVariable "temp"
			free pHKO
			pHKO = tmpHKO +"\\HKXtoXML.hko"
			startInt = str.count
			startInt = startInt-3
			str = replace str startInt 4 ".xml"
			if pHKO != undefined then
				(	
				outHKO = createfile pHKO				
				format "%\n" "<?xml version=\"1.0\" encoding=\"utf-8\"?>" to:outHKO
				format "%\n" "<hkoptions>" to:outHKO
				format "%\n" "	<hkobject class=\"hctConfigurationSetData\">" to:outHKO
				format "%\n" "		<hkparam name=\"filterManagerVersion\">65536</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"activeConfiguration\">0</hkparam>" to:outHKO
				format "%\n" "	</hkobject>" to:outHKO
				format "%\n" "	<hkobject class=\"hctConfigurationData\">" to:outHKO
				format "%\n" "		<hkparam name=\"configurationName\">conversion</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"numFilters\">1</hkparam>" to:outHKO
				format "%\n" "	</hkobject>" to:outHKO
				format "%\n" "	<hkobject name=\"Write to Platform\" class=\"hctFilterData\">" to:outHKO
				format "%\n" "		<hkparam name=\"id\">2876798309</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"ver\">66048</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"hasOptions\">true</hkparam>" to:outHKO
				format "%\n" "	</hkobject>" to:outHKO
				format "%\n" "	<hkobject name=\"Write to Platform\" class=\"hctPlatformWriterOptions\">" to:outHKO
				format "%"    "		<hkparam name=\"filename\">" to:outHKO
				format "%"    str to:outHKO
				format "%\n" "</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"tagfile\">true</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"preset\">MSVC_WIN32</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"bytesInPointer\">4</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"littleEndian\">1</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"reusePaddingOptimized\">0</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"emptyBaseClassOptimized\">1</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"removeMetadata\">false</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"userTag\">0</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"saveEnvironmentData\">false</hkparam>" to:outHKO
				format "%\n" "		<hkparam name=\"xmlFormat\">true</hkparam>" to:outHKO
				format "%\n" "	</hkobject>" to:outHKO
				format "%\n" "</hkoptions>" to:outHKO
				close outHKO
			)				
		),
		
		fn createCamHU = (
		EnvironmentHU = dotNetClass "System.Environment"
		tmpHU = EnvironmentHU.GetEnvironmentVariable "temp"
			free pHuman
			pHuman = tmpHU +"\\HKXtoBIP_human.cam"
			if pHuman != undefined then
				(	
				outHU = createfile pHuman
				
				format "%\n" "[Header]" to:outHU
				format "%\n" "Version:3500" to:outHU
				format "%\n" "RigName:Bip_" to:outHU
				format "%\n" "Frequency:1" to:outHU
				format "%\n" "[Data]" to:outHU
				format "%\n" "SceneRootNode.Hub=\"Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.ArbBone[0]=\"Camera\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.ArbBone[1]=\"CamTargset\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.ArbBone[2]=\"Root\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"Spine1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Chest\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0]=\"WeaponLeft\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0].ArbBone[0]=\"WeaponIKTargsetR\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0].ArbBone[1]=\"WeaponIKTargsetRMirror\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0]=\"Weapon\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[0]=\"WeaponBolt\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[1]=\"WeaponExtra1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[2]=\"WeaponExtra2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[3]=\"WeaponExtra3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[4]=\"WeaponOptics1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[5]=\"WeaponOptics2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[6]=\"WeaponTrigger\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[7]=\"WeaponIKTargsetL\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[8]=\"WeaponIKTargsetLMirror\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9]=\"WeaponMagazine\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[0]=\"WeaponMagazineChild1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[1]=\"WeaponMagazineChild2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[2]=\"WeaponMagazineChild3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[3]=\"WeaponMagazineChild4\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[4]=\"WeaponMagazineChild5\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outHU
				close outHU
				
				)
		),

		fn createCamGH = (
		EnvironmentGH = dotNetClass "System.Environment"
		tmpGH  = EnvironmentGH.GetEnvironmentVariable "temp"
			free pGhoul
			pGhoul = tmpGH +"\\HKXtoBIP_ghoul.cam"
			if pGhoul != undefined then
				(
				outGH = createfile pGhoul
					
				format "%\n" "[Header]" to:outGH
				format "%\n" "Version:3500" to:outGH
				format "%\n" "RigName:Bip_" to:outGH
				format "%\n" "Frequency:1" to:outGH
				format "%\n" "[Data]" to:outGH
				format "%\n" "SceneRootNode.Hub=\"Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LThigh\" (matrix3 [0.998707,-0.033119,-0.0385556] [0.0205686,0.957022,-0.289287] [0.0464794,0.28812,0.956466] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LCalf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LFoot\" (matrix3 [0.972299,-0.233678,-0.00539169] [0.233728,0.972228,0.0119887] [0.00244044,-0.0129167,0.999914] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LToe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RThigh\" (matrix3 [0.999785,-0.0204171,-0.00365693] [0.0207117,0.973158,0.229203] [-0.00112089,-0.22923,0.973372] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RCalf\" (matrix3 [0.999745,-0.000272205,-0.022575] [0.00664322,0.959205,0.282632] [0.0215772,-0.28271,0.958963] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RFoot\" (matrix3 [0.959473,-0.281718,0.00686926] [0.28179,0.95937,-0.0142447] [-0.00257719,0.0156031,0.999875] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RToe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"SpineRoot\" (matrix3 [0.996729,0.0808122,0] [-0.0808122,0.996729,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine1\" (matrix3 [0.986939,0.161096,0] [-0.161096,0.986939,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Spine2\" (matrix3 [0.996729,0.0808124,0] [-0.0808122,0.99673,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LCollarbone\" (matrix3 [0.84691,0.47902,0.230831] [-0.492719,0.870186,0.00195749] [-0.199929,-0.115393,0.972992] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LUpperArm\" (matrix3 [0.999209,-0.0394851,0.00462876] [-0.037512,-0.89784,0.438721] [-0.0131675,-0.438548,-0.898612] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LForeArm1\" (matrix3 [0.998535,-0.0221422,0.0493774] [0.0515579,0.666427,-0.743786] [-0.0164374,0.745242,0.666592] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LHand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LThumb\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LThumb1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LThumb2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LIndex\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LIndex1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LIndex2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LMiddle\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LMiddle1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LMiddle2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LRing\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LRing1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LRing2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LPinky\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LPinky1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LPinky2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RCollarbone\" (matrix3 [0.840371,0.495526,-0.219616] [-0.516956,0.854549,-0.0500126] [0.16289,0.155561,0.974304] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RUpperArm\" (matrix3 [0.998169,-0.00877196,-0.059816] [-0.0235503,-0.967682,-0.25107] [-0.0556808,0.252019,-0.966118] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RForeArm1\" (matrix3 [0.985394,-0.117378,-0.123386] [0.154546,0.920698,0.358379] [0.0715345,-0.372212,0.925389] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RHand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RThumb\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RThumb1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RThumb2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RIndex\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RIndex1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RIndex2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RMiddle\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RMiddle1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RMiddle2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RRing\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RRing1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RRing2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RPinky\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RPinky1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RPinky2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outGH
				close outGH
			)
		),

		fn createCamSM = (	
			EnvironmentSM = dotNetClass "System.Environment"
			tmpSM  = EnvironmentSM.GetEnvironmentVariable "temp"
			free pSuperMutant
			pSuperMutant = tmpSM +"\\HKXtoBIP_supermutant.cam"
			if pSuperMutant != undefined then
				(	
				outSM = createfile pSuperMutant

				format "%\n" "[Header]" to:outSM
				format "%\n" "Version:3500" to:outSM
				format "%\n" "RigName:Bip_" to:outSM
				format "%\n" "Frequency:1" to:outSM
				format "%\n" "[Data]" to:outSM
				format "%\n" "SceneRootNode.Hub=\"Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [-20.4742,0,-1.83053e-005])" to:outSM
				format "%\n" "SceneRootNode.Hub.ArbBone[2]=\"Root\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"Spine1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Chest\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0]=\"WeaponLeft\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0]=\"Weapon\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[0]=\"WeaponBolt\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[1]=\"WeaponExtra1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[2]=\"WeaponExtra2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[3]=\"WeaponExtra3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[4]=\"WeaponOptics1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[5]=\"WeaponOptics2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[6]=\"WeaponTrigger\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[7]=\"WeaponIKTargsetL\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[8]=\"WeaponIKTargsetR\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9]=\"WeaponMagazine\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[0]=\"WeaponMagazineChild1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[1]=\"WeaponMagazineChild2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[2]=\"WeaponMagazineChild3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[3]=\"WeaponMagazineChild4\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[4]=\"WeaponMagazineChild5\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:outSM
				close outSM
			)
		),

		fn createCamF76 = (	
			EnvironmentF76 = dotNetClass "System.Environment"
			tmpF76  = EnvironmentF76.GetEnvironmentVariable "temp"
			free pF76
			pF76 = tmpF76 +"\\HKXtoBIP_fallout76.cam"
			if pF76 != undefined then
				(
				out76 = createfile pF76
			
				format "%\n" "[Header]" to:out76
				format "%\n" "Version:3500" to:out76
				format "%\n" "RigName:Bip_" to:out76
				format "%\n" "Frequency:1" to:out76
				format "%\n" "[Data]" to:out76
				format "%\n" "SceneRootNode.Hub])Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.ArbBone[2]=\"Root\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"Spine1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Chest\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0]=\"WeaponLeft\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0]=\"Weapon\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[0]=\"WeaponBolt\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[1]=\"WeaponExtra1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[2]=\"WeaponExtra2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[3]=\"WeaponExtra3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[4]=\"WeaponOptics1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[5]=\"WeaponOptics2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[6]=\"WeaponTrigger\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9]=\"WeaponMagazine\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[0]=\"WeaponMagazineChild1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[1]=\"WeaponMagazineChild2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[2]=\"WeaponMagazineChild3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[3]=\"WeaponMagazineChild4\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[4]=\"WeaponMagazineChild5\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0]we.Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
				format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out76
			
					
				close out76
			)
		),

		fn collect_children obj &allChildren includeParent:true includeHidden:true = (
			-- check if object should be collected
			if (includeHidden or not obj.isHiddenInVpt) and includeParent and finditem allChildren obj == 0 then
				append allChildren obj

			-- collect current object's children
			for c in obj.children do collect_children c &allChildren includeParent:true includeHidden:includeHidden
			
		),

		fn renObjSub obj toDelete RootSrc = (
			if RootSrc !=undefined then (
				select RootSrc
				for obj in selection do collect_children obj &allChildren
				select allChildren
			)	

			if switch == 1 and RootSrc != $Root_Source then (
				for i=1 to obj.count do 
					(
						tokens = substring obj[i].name 1 (obj[i].name.count - toDelete)
						obj[i].name = tokens
						setUserPropBuffer obj[i] userprops_human[i]
					)
			)
			
			if switch == 2 and RootSrc != $Root_Source then (
				for i=1 to obj.count do 
					(
						tokens = substring obj[i].name 1 (obj[i].name.count - toDelete)
						obj[i].name = tokens
						setUserPropBuffer obj[i] userprops_ghoul[i]
					)
			)
			
			if switch == 3 and RootSrc != $Root_Source then (
				for i=1 to obj.count do 
					(
						tokens = substring obj[i].name 1 (obj[i].name.count - toDelete)
						obj[i].name = tokens
						setUserPropBuffer obj[i] userprops_supermutant[i]
					)
			)
			
			if switch == 4 and RootSrc != $Root_Source then (
				for i=1 to obj.count do 
					(
						tokens = substring obj[i].name 1 (obj[i].name.count - toDelete)
						obj[i].name = tokens
						setUserPropBuffer obj[i] userprops_fallout76[i]
					)
			)
			
			if RootSrc == $Root_Source then (
				for i=1 to obj.count do 
					(
						tokens = substring obj[i].name 1 (obj[i].name.count - toDelete)
						obj[i].name = tokens
					)
			)
			
				
			deselect selection
		),

		fn renObjAdd obj addition = (
			if $Root != undefined then (	
				select $Root
				for obj in selection do collect_children obj &allChildren
				select allChildren
					for i=1 to obj.count do 
					(
						obj[i].name = append obj[i].name addition
						objectsProp = ""
						setUserPropBuffer obj[i] objectsProp
					)
					
				free obj
			)
		),
		
		fn resetObjNames = (
			deselect $*
			if $Root != undefined then (
			select $Root
			for obj in selection do collect_children obj &allChildren
			
				for i = 1 to allChildren.count do (	
						if switch == 1 then (
							renObjAdd allChildren "_human"
						)
				)
					for i = 1 to allChildren.count do (	
						if switch == 2 then (
							renObjAdd allChildren "_ghoul"
						)
				)
					for i = 1 to allChildren.count do (	
						if switch == 3 then (
							renObjAdd allChildren "_supermutant"
						)
				)
					for i = 1 to allChildren.count do (	
						if switch == 4 then (
							renObjAdd allChildren "_fallout76"
						)
						
				)
			)
		),

		fn collapAnimLayer = (
					$Bip_.AppendLayer "Animation Layer" #absolute
					$Bip_.CollapseTimeRangeToLayer animationRange.start animationRange.end 1 regularplot:true NumPasses:2 PosDeltaThreshold: 2.0 RotDeltaThreshold: 5.0 
					LayNum = $Bip_.NumLayers
					for i = 1 to LayNum-1 do
					(
					$Bip_.RemoveLayer 1
					)				
					$Bip_.SelectedLayer=1
					$Bip_.SoloLayer=1
					$Bip_.SoloLayer=0
					$Bip_.SoloLayer=1
					$Bip_.SoloLayer=0
		), 
		
		fn CheckedChanged sender args = (
			hkxImporter.dnHkxList.AllowDrop=true
			hkxImporter.dnHkxList.Enabled=true
			hkxImporter.dnAnnotationList.AllowDrop=true
			hkxImporter.dnAnnotationList.Enabled=true
			hkxImporter.dnBtnBrowse.Enabled=true

			
			if $Bip_ != undefined do (		
					hkxImporter.switch = sender.TabIndex
							if hkxImporter.switch == 1 and hkxImporter.BtnState != 1 then (
								if hkxImporter.BtnState == 2 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_ghoul"
								)
								
								if hkxImporter.BtnState == 3 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_supermutant"
								)
								
								if hkxImporter.BtnState == 4 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_fallout76"
								)
								hkxImporter.renObjSub hkxImporter.allChildren 6 $Root_human
								hkxImporter.BtnState = 1
							)
			
							if hkxImporter.switch == 2 and hkxImporter.BtnState != 2 then (
								hkxImporter.switch = sender.TabIndex
								if hkxImporter.BtnState == 1 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_human"
								)
								if hkxImporter.BtnState == 3 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_supermutant"
								)
								if hkxImporter.BtnState == 4 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_fallout76"
								)
								
								hkxImporter.renObjSub hkxImporter.allChildren 6  $Root_ghoul
								hkxImporter.BtnState = 2
							)
			
							if hkxImporter.switch == 3 and hkxImporter.BtnState != 3 then (
								hkxImporter.switch = sender.TabIndex
								if hkxImporter.BtnState == 1 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_human"
								)
								if hkxImporter.BtnState == 2 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_ghoul"
								)
								if hkxImporter.BtnState == 4 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_fallout76"
								)
							
								hkxImporter.renObjSub hkxImporter.allChildren 12 $Root_supermutant
								hkxImporter.BtnState = 3
							)
							
							if hkxImporter.switch == 4 and hkxImporter.BtnState != 4 then (
								hkxImporter.switch = sender.TabIndex
								if hkxImporter.BtnState == 1 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_human"
								)
								if hkxImporter.BtnState == 2 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_ghoul"
								)
								if hkxImporter.BtnState == 3 then (
									hkxImporter.renObjAdd hkxImporter.allChildren "_supermutant"
								)				
								hkxImporter.renObjSub hkxImporter.allChildren 10  $Root_fallout76
								hkxImporter.BtnState = 4
							)
			)
		),
		
		fn collectUserProps = (
			
			if $Root_human != undefined then (
				select $Root_human
				for obj in selection do collect_children obj &allChildren
				select allChildren
				obj_tmp = allChildren
				objectnames_human = obj_tmp
			
					for i=1 to obj_tmp.count do ( 
					userprops_human[i] = getUserPropBuffer obj_tmp[i]
					setUserPropBuffer obj_tmp[i] ""
					)
					
				free obj
				free obj_tmp
				free allChildren
				deselect $
			)
			
			if $Root_ghoul != undefined then (
				select $Root_ghoul
					for obj in selection do collect_children obj &allChildren
				select allChildren
				obj_tmp = allChildren
				objectnames_ghoul = obj_tmp		
				
					for i=1 to obj_tmp.count do ( 
					userprops_ghoul[i] = getUserPropBuffer obj_tmp[i]
					setUserPropBuffer obj_tmp[i] ""
					)
			
				free obj
				free obj_tmp
				free allChildren
				deselect $
			)
			
			if $Root_supermutant != undefined then (
				select $Root_supermutant
				for obj in selection do collect_children obj &allChildren
				select allChildren
				obj_tmp = allChildren
				objectnames_supermutant = obj_tmp
			
					for i=1 to obj_tmp.count do ( 
					userprops_supermutant[i] = getUserPropBuffer obj_tmp[i]
					setUserPropBuffer obj_tmp[i] ""
					)
					
				free obj
				free obj_tmp
				free allChildren
				deselect $
			)
			
			if $Root_fallout76 != undefined then (
				select $Root_fallout76
				for obj in selection do collect_children obj &allChildren
				select allChildren
				obj_tmp = allChildren
				objectnames_fallout76 = obj_tmp 
			
					for i=1 to obj_tmp.count do ( 
					userprops_fallout76[i] = getUserPropBuffer obj_tmp[i]
					setUserPropBuffer obj_tmp[i] ""
					)
					
				free obj
				free obj_tmp
				free allChildren
				deselect $
			)
		),
		
		fn initLeftPanelTop sender = (
			
		dnFontBig = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "Arial") 8.5  (dotNetClass "system.drawing.fontStyle").bold	
		dnFontSmall = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "Arial") 5.5 (dotNetClass "system.drawing.fontStyle").bold	
			
			
		dnFlow=dotNetObject "flowLayoutPanel"
		dnFlow.FlowDirection=dnFlow.FlowDirection.TopDown
		dnFlow.bounds=dnRec s:[sender.width, sender.height*0.8]
		dnFlow.BorderStyle=dnFlow.BorderStyle.none
		sender.controls.add dnFlow
			
		dnLabel=dotNetObject "Label"
		dnLabel.size=dnSize s:[sender.width-6, sender.height*0.1]
		dnLabel.text="Select Source Race:"
		dnLabel.ForeColor=dnColor c:[255,255,255] a:255
		dnLabel.Font=dnFontBig	
		dnFlow.controls.add dnLabel
			
		dnSpacer=dotNetObject "Label"
		dnSpacer.size=dnSize s:[sender.width-6, sender.height*0.1]
		dnSpacer.text=""
		dnSpacer.ForeColor=dnColor c:[255,255,255] a:255
		dnFont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "Arial") 8.5  (dotNetClass "system.drawing.fontStyle").bold	
		dnSpacer.Font=dnFontSmall	
		dnFlow.controls.add dnSpacer
			
		dnRadioBtnOne=dotNetObject "RadioButton"
		dnRadioBtnOne.size=dnSize s:[sender.width-6, sender.height*0.1]
		dnFont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "Arial") 5.5 (dotNetClass "system.drawing.fontStyle").bold	
		dnRadioBtnOne.Font=dnFontSmall	
		dnRadioBtnOne.TabIndex=1
		dnRadioBtnOne.text="Human"
		dnRadioBtnOne.ForeColor=dnColor c:[255,255,255] a:255
		dnFlow.controls.add dnRadioBtnOne
		
		dotNet.addEventHandler dnRadioBtnOne "Click" CheckedChanged
		dotNet.setLifeTimeControl dnRadioBtnOne #dotNet		
		
		dnRadioBtnTwo=dotNetObject "RadioButton"
		dnRadioBtnTwo.size=dnSize s:[sender.width-6, sender.height*0.1]
		dnFont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "Arial") 5.5 (dotNetClass "system.drawing.fontStyle").bold	
		dnRadioBtnTwo.Font=dnFontSmall
		dnRadioBtnTwo.TabIndex=2
		dnRadioBtnTwo.text="Ghoul"
		dnRadioBtnTwo.ForeColor=dnColor c:[255,255,255] a:255
		dnFlow.controls.add dnRadioBtnTwo
		
		dotNet.addEventHandler dnRadioBtnTwo "Click" CheckedChanged
		dotNet.setLifeTimeControl dnRadioBtnTwo #dotNet		
		
		dnRadioBtnThree=dotNetObject "RadioButton"
		dnRadioBtnThree.size=dnSize s:[sender.width-6, sender.height*0.1]
		dnRadioBtnThree.Font=dnFontSmall
		dnRadioBtnThree.TabIndex=3
		dnRadioBtnThree.text="Super Mutant"
		dnRadioBtnThree.ForeColor=dnColor c:[255,255,255] a:255
		dnFlow.controls.add dnRadioBtnThree
		
		dotNet.addEventHandler dnRadioBtnThree "Click" CheckedChanged
		dotNet.setLifeTimeControl dnRadioBtnThree #dotNet		
		
		dnRadioBtnFour=dotNetObject "RadioButton"
		dnRadioBtnFour.size=dnSize s:[sender.width-6, sender.height*0.1]
		dnFont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "Arial") 5.5 (dotNetClass "system.drawing.fontStyle").bold	
		dnRadioBtnFour.Font=dnFontSmall
		dnRadioBtnFour.TabIndex=4
		dnRadioBtnFour.text="Fallout 76 Human"
		dnRadioBtnFour.ForeColor=dnColor c:[255,255,255] a:255
		dnFlow.controls.add dnRadioBtnFour
		
		dotNet.addEventHandler dnRadioBtnFour "Click" CheckedChanged
		dotNet.setLifeTimeControl dnRadioBtnFour #dotNet		

		),
		
		fn dnHkxListDragEnter sender args = (
			if (args.Data.GetData(dotnetclass "DataFormats").filedrop) != undefined then
			(
				args.Effect = (dotNetClass "System.Windows.Forms.DragDropEffects").Copy
			) else (
				args.Effect = (dotNetClass "System.Windows.Forms.DragDropEffects").None
			)
		),
		
		fn dnHkxListDragDrop sender args = (
			rows = #()
			hkxImporter.dnBtnRun.Enabled=true
			
			hkxImporter.hkxPath = args.Data.GetData(dotnetclass "DataFormats").filedrop
			li=dotNetObject "System.Windows.Forms.ListViewItem" hkxImporter.hkxPath	
				
			print hkxImporter.dnHkxList.items.count
			print li.text
			
			if  li.text != undefined then (
		
	-- 			if hkxImporter.dnHkxList.items.count == 0 then (		
					
						hkxImporter.dnHkxList.items.clear()
						hkxImporter.dnHkxList.items.add li
						mImPath = hkxImporter.dnHkxList
					
						hkxImporter.hkxPath= li.text
						conStr = li.text as string
						importFile conStr #noPrompt using:HavokImport
						hkxImporter.createHKOconfig(conStr)
						
						scptPath = getThisScriptFilename() as string
						scptPath = getFilenamePath scptPath
						
						EXEPath = scptPath + "hkxreano.exe" 
						hkxImporter.hkxreano EXEPath arg_array:#(conStr) 
						hkxImporter.initXMLPanel(conStr)
	-- 			)	
			)	
			
	-- 			) else (
	-- 						
	-- 					switchtmp = hkxImporter.switch
	-- 					
	-- 					hkxImporter.dnHkxList.items.clear()
	-- 					hkxImporter.dnHkxList.items.add li
	-- 					mImPath = hkxImporter.dnHkxList
	-- 					
	-- 					if $Root_Source != undefined then (
	-- 							if hkxImporter.ntp1 != undefined then (
	-- 								deleteNoteTrack $Root_Source hkxImporter.ntp1 
	-- 							)
	-- 					) else (
	-- 							if hkxImporter.ntp1 != undefined then (
	-- 								deleteNoteTrack $Root hkxImporter.ntp1
	-- 							)
	-- 					)
	-- 					hkxImporter.ntp1= undefined
	-- 					hkxImporter.resetBipFile()
	-- 				
	-- 					if switchtmp == 1 then (hkxImporter.dnRadioBtnOne.Click())
	-- 					if switchtmp == 2 then (hkxImporter.dnRadioBtnTwo.Click())
	-- 					if switchtmp == 3 then (hkxImporter.dnRadioBtnThree.Click())
	-- 					if switchtmp == 4 then (hkxImporter.dnRadioBtnFour.Click())

	-- 					hkxImporter.hkxPath= li.text
	-- 					conStr = li.text as string
	-- 					importFile conStr #noPrompt using:HavokImport
	-- 					hkxImporter.createHKOconfig(conStr)
	-- 					
	-- 					scptPath = getThisScriptFilename() as string
	-- 					scptPath = getFilenamePath scptPath
	-- 					
	-- 					EXEPath = scptPath + "hkxreano.exe" 
	-- 					hkxImporter.hkxreano EXEPath arg_array:#(conStr) 
	-- 					hkxImporter.initXMLPanel(conStr)
	-- 				)
				
	-- 		)
		),
		
		fn dnHkxListImportManual conStr= (
			li=dotNetObject "System.Windows.Forms.ListViewItem" hkxImporter.hkxPath
			hkxImporter.dnHkxList.items.clear()
			hkxImporter.dnHkxList.items.add li
			formatProps hkxImporter.dnBtnRun

			importFile conStr /*#noPrompt*/ using:HavokImport
				if conStr != "" then 
				( 
					hkxImporter.dnBtnRun.Enabled=true
					hkxImporter.createHKOconfig(conStr)
					scptPath = getThisScriptFilename() as string
					scptPath = getFilenamePath scptPath
					
					EXEPath = scptPath + "hkxreano.exe" 
					hkxImporter.hkxreano EXEPath arg_array:#(conStr) 
					hkxImporter.initXMLPanel(conStr)
				)
		),
		
		fn dnBtnShowXMLClick sender args = (
			startInt = hkxImporter.hkxPath.count
			startInt = startInt-3
			str = replace hkxImporter.hkxPath startInt 4 ".xml"
			if str != undefined then 
			(
			shellLaunch str ""
			)
		),
		
		fn dnBtnHelpClick sender args = (
		),
		
		fn dnBtnRunClick sender args = (
			hkxImporter.runAnimTransfer()
		),
		
		fn dnBtnResetClick sender args = (
			destroyDialog unInst
			loadMaxFile (maxFilePath + maxFileName) quiet:true
			fileIn(getThisScriptFilename()) 
		),
		
		fn dnBtnBrowseClick sender args = (
			ofd = DotNetObject "System.Windows.Forms.OpenFileDialog"
			ofd.Title = "Havok Animation File..."
			ofd.Filter = "Havok Animation File(*.hkx)|*.hkx"
			ofd.InitialDirectory = maxFilepath
			ofd.Multiselect = false
			ofdResult = ofd.ShowDialog()
			ofdResult.toString()
			mImPath = ofd.fileName
			conStr = mImPath as string
			
				if conStr != undefined then (
					hkxImporter.hkxPath=mImPath
					hkxImporter.dnHkxListImportManual conStr
				)
		),
		
		fn dnAnnotationListDoubleClick = (
			
		),
		
		fn initLeftPanelBot sender = (
			
		dnFlow=dotNetObject "flowLayoutPanel"
		dnFlow.FlowDirection=dnFlow.FlowDirection.LeftToRight
		dnFlow.bounds=dnRec s:[sender.width, sender.height*0.8]
		dnFlow.BorderStyle=dnFlow.BorderStyle.none
		sender.controls.add dnFlow
			
		dnBtnBrowse=dotNetObject "Button"
		dnBtnBrowse.Dock.Fill
		dnBtnBrowse.text="Import *.hkx"
		dnBtnBrowse.name="Browse"		
		dnBtnBrowse.height=25
		dnBtnBrowse.Enabled=false
		dnBtnBrowse.width=sender.width-8
		dnBtnBrowse.ForeColor=dnColor c:[255,255,255] a:255
		dnFlow.controls.add dnBtnBrowse
			
		dotNet.addEventHandler dnBtnBrowse "Click" dnBtnBrowseClick
		dotNet.setLifeTimeControl dnBtnBrowse #dotNet			
					
			
		dnBtnRun=dotNetObject "Button"
		dnBtnRun.size=dnSize s:[sender.width*0.3, sender.height*0.4]
		dnBtnRun.text="Run"
		dnBtnRun.name="Run"
		dnBtnRun.Enabled=false
		dnBtnRun.ForeColor=dnColor c:[255,255,255] a:255
		dnFlow.controls.add dnBtnRun
			
		dotNet.addEventHandler dnBtnRun "Click" dnBtnRunClick
		dotNet.setLifeTimeControl dnBtnRun #dotNet			
			
		dnBtnReset=dotNetObject "Button"
		dnBtnReset.size=dnSize s:[sender.width*0.3, sender.height*0.4]
		dnBtnReset.text="Reset"
		dnBtnReset.name="Reset"
		dnBtnReset.ForeColor=dnColor c:[255,255,255] a:255
		dnFlow.controls.add dnBtnReset
		
		dotNet.addEventHandler dnBtnReset "Click" dnBtnResetClick
		dotNet.setLifeTimeControl dnBtnReset #dotNet			

			
		dnBtnHelp=dotNetObject "Button"
		dnBtnHelp.size=dnSize s:[sender.width*0.3, sender.height*0.4]
		dnBtnHelp.text="Help"
		dnBtnHelp.name="Help"
		dnBtnHelp.ForeColor=dnColor c:[255,255,255] a:255
		dnFlow.controls.add dnBtnHelp
				
		dotNet.addEventHandler dnBtnHelp "Click" dnBtnHelpClick
		dotNet.setLifeTimeControl dnBtnHelp #dotNet			
		),
		
		fn initsplitControlLeft sender = (
			sender.backColor=dnColor c:(maxBackColor*255) a:255
			sender.orientation=sender.orientation.horizontal
			sender.splitterDistance=200
			sender.splitterWidth=20
			sender.IsSplitterFixed=true
			sender.AllowDrop=true
			
			dotNet.addEventHandler sender "DragEnter" dnHkxListDragEnter
			dotNet.addEventHandler sender "DragDrop" dnHkxListDragDrop
			dotNet.setLifeTimeControl sender #dotNet

		),
		
		fn initLeftPanel sender = (
			splitControlLeft=dotNetObject "system.windows.forms.splitContainer" \
			width:(sender.width-5) \
			height:(sender.height-5) \
			offset:[-50,-2]
			splitControlLeft.size=dnSize s:[200, 300]
			
			initsplitControlLeft splitControlLeft
			sender.controls.add splitControlLeft
			initLeftPanelTop splitControlLeft.Panel1
			initLeftPanelBot splitControlLeft.Panel2
		),
			
		fn initRightPanel sender = (
			dnFlow=dotNetObject "flowLayoutPanel"
			dnFlow.FlowDirection=dnFlow.FlowDirection.TopDown
			dnFlow.bounds=dnRec s:[sender.width, sender.height]
			dnFlow.BorderStyle=dnFlow.BorderStyle.none
			sender.controls.add dnFlow
			
			dnHkxList=dotNetObject "ListView"
			dnHkxList.size=dnSize s:[sender.width-6,sender.height*0.3]
			dnHkxList.view=(dotNetClass "system.windows.forms.view").details
			dnHkxList.FullRowSelect=true
			dnHkxList.GridLines=true
			dnHkxList.MultiSelect=false
			dnHkxList.AllowDrop=false
			dnHkxList.Enabled=false
			dnHkxList.columns.add "HKX-File:" (sender.width+1000)
			dnFlow.controls.add dnHkxList
			
	 		dotNet.addEventHandler dnHkxList "DragEnter" dnHkxListDragEnter
	 		dotNet.addEventHandler dnHkxList "DragDrop" dnHkxListDragDrop
	 		dotNet.setLifeTimeControl dnHkxList #dotNet
			

			dnAnnotationList=dotNetObject "ListView"
			dnAnnotationList.size=dnSize s:[sender.width-6,sender.height*0.55]
			dnAnnotationList.view=(dotNetClass "system.windows.forms.view").details
			dnAnnotationList.FullRowSelect=true
			dnAnnotationList.GridLines=true
			dnAnnotationList.MultiSelect=false
			dnAnnotationList.AllowDrop=false
			dnAnnotationList.Enabled=false
			dnAnnotationList.Activation=(dotNetClass "System.Windows.Forms.ItemActivation").TwoClick
			dnAnnotationList.columns.add "Annotations:" (sender.width/2)
			dnAnnotationList.columns.add "Frame:" (sender.width/2)
			dnFlow.controls.add dnAnnotationList
			
			dotNet.addEventHandler dnAnnotationList "MouseDoubleClick" dnAnnotationListDoubleClick
			dotNet.addEventHandler dnAnnotationList "DragEnter" dnHkxListDragEnter
			dotNet.addEventHandler dnAnnotationList "DragDrop" dnHkxListDragDrop
			dotNet.setLifeTimeControl dnAnnotationList #dotNet
			
			
			dnBtnShowXML=dotNetObject "Button"
			dnBtnShowXML.Dock.Fill
			dnBtnShowXML.text="Show XML-File"
			dnBtnShowXML.name="xml"
			dnBtnShowXML.width=270
			dnBtnShowXML.ForeColor=dnColor c:[255,255,255] a:255
			dnFlow.controls.add dnBtnShowXML
			
			dotNet.addEventHandler dnBtnShowXML "Click" dnBtnShowXMLClick
			dotNet.setLifeTimeControl dnBtnShowXML #dotNet			
		),
		
		fn initsplitControlMain sender = (
			sender.backColor=dnColor c:(maxBackColor*255) a:255
			sender.orientation=sender.orientation.vertical
			sender.splitterDistance=200
			sender.splitterWidth=20
			sender.IsSplitterFixed=true

		),
		
		fn runAnimTransfer = (		
			if (classOf $Root) != BoneGeometry then 
			(
				if switch == 1 then (
				free allChildren	
								if $Root != undefined do ( 			
									AnimTransfer $Bip_ $Root pHuman
									resetObjNames()
									renObjSub allChildren 7 $Root_Source
									collapAnimLayer()
									select $Bip_
								)
				)
				
				if switch == 2 then (
				free allChildren	
								if $Root != undefined do ( 			
									AnimTransfer $Bip_ $Root pGhoul
									resetObjNames()
									renObjSub allChildren 7 $Root_Source
									collapAnimLayer()
									select $Bip_
								)
					
				)
				
				if switch == 3 then 
				(
							free allChildren
								if $Root != undefined do 
								( 			
									AnimTransfer $Bip_ $Root pSuperMutant
									resetObjNames()
									renObjSub allChildren 7 $Root_Source
									collapAnimLayer()
									select $Bip_
								)
				)
						
				if switch == 4 then 
				(
							free allChildren
								if $Root != undefined do 
								( 			
									AnimTransfer $Bip_ $Root pF76
									resetObjNames()
									renObjSub allChildren 7 $Root_Source
									collapAnimLayer()
									select $Bip_
								)
				)
			)
		),
		

			
		fn ui = (
			rollout uiR "hkx Importer for Fallout 4 by Sebbo" width:500 height:300
			(
				dotNetControl splitControlMain "system.windows.forms.splitContainer" \
				width:(uiR.width-5) \
				height:(uiR.height-5) \
				offset:[-10,-2]
				
				on uiR open do 
				(
					initsplitControlMain splitControlMain
					initLeftPanel splitControlMain.Panel1
					initRightPanel splitControlMain.Panel2
				)
			) 
			
			createDialog uiR
			unInst=uiR
		),
			
		fn run = (
			runCheck()
			if unInst==undefined then
			(
				collectUserProps()
				createCamHU()
				createCamGH()
				createCamSM()
				createCamF76()
				ui()
				
			) else (
				destroyDialog unInst
				unInst = undefined
				run()
			)
		)
	)

	hkxImporter=hkxImporter()
	hkxImporter.run()