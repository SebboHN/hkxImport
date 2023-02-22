-----------------------------------------------------------------------------
--		HKXImport / Mapping Script by Sebbo
-----------------------------------------------------------------------------
-------------------------------------------------------
-- General
		global allChildren = #()
		global BtnState = 0
		global RootSrc
		global switch
		global obj = #()
		global inaktiv
		global obj_tmp = #()
-------------------------------------------------------
-- Human
		global objectnames_human
		global out_path_human
		global skel_human = #()
		global userprops_human = #()
-------------------------------------------------------
-- Ghoul
		global objectnames_ghoul
		global out_path_ghoul
		global skel_ghoul = #()
		global userprops_ghoul = #()
-------------------------------------------------------
-- Supermutant
		global objectnames_supermutant
		global userprops_supermutant = #()
		global skel_supermutant = #()
		global out_path_supermutant		
-------------------------------------------------------
-- Fallout 76
		global objectnames_fallout76
		global userprops_fallout76 = #()
		global skel_fallout76 = #()
		global out_path_fallout76
		
fn capture_animation catparentnode source_hierarchy_root camfile quiet:true delsrc:false StartTime:animationRange.start EndTime:animationRange.end layername:"" = 
(		
	print "---------------" 	
	print "Transfering Animation"
	
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
	
	rCaptureAnim.source_nodes = #(source_hierarchy_root);
	rCaptureAnim.updateSource();
	
	if layername.count > 0 then
		rCaptureAnim.targetLayerName = layername;
	else if source_hierarchy_root != undefined then
		rCaptureAnim.targetLayerName = source_hierarchy_root.name;
		
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
	
)

fn collect_children obj &allChildren includeParent:true includeHidden:true =
(
	-- check if object should be collected
	if (includeHidden or not obj.isHiddenInVpt) and includeParent and finditem allChildren obj == 0 then
		append allChildren obj

	-- collect current object's children
	for c in obj.children do collect_children c &allChildren includeParent:true includeHidden:includeHidden
	
)

fn rename_objects_substract obj toDelete RootSrc=
(
	print "true" 
	print "---------------" 	 	
	print "Object Renaming"
	select RootSrc
	for obj in selection do collect_children obj &allChildren
	select allChildren

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
	
		
	print "true" 	
	deselect selection
)

fn change_names_back = (
	print "---------------" 	
	print "Changing names back"
	select $Root
	for obj in selection do collect_children obj &allChildren
	print allChildren	
		for i = 1 to allChildren.count do (	
			if switch == 1 then (
				obj[i].name = objectnames_human[i].name
				rename_objects_addition allChildren "_human"
			)
		)
		
			for i = 1 to allChildren.count do (	
			if switch == 2 then (
				obj[i].name = objectnames_ghoul[i].name
				rename_objects_addition allChildren "_ghoul"
			)
		)
			for i = 1 to allChildren.count do (	
			if switch == 3 then (
				obj[i].name = objectnames_supermutant[i].name
				rename_objects_addition allChildren "_supermutant"
			)
		)
		for i = 1 to allChildren.count do (	
			if switch == 4 then (
		--		obj[i].name = objectnames_fallout76[i].name
				rename_objects_addition allChildren "_fallout76"
			)
		)
)

fn rename_objects_addition obj addition =
(
	print "true" 
	print "---------------"
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
		print "true" 	
	)
)

fn cleanup_layer = 
(
			print "---------------" 	
			print "Cleanup" 	
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
			print "true" 	
) 
 
fn create_mapping_file_human = 
(

Environment_human = dotNetClass "System.Environment"
temp_human = Environment_human.GetEnvironmentVariable "temp"
	free out_path_human
	out_path_human = temp_human +"\\HKXtoBIP_human.cam"
	if out_path_human != undefined then
		(
		print "---------------" 
		print "Create Mapping File "+ out_path_human 	
	
		out_file_human = createfile out_path_human
		
		format "%\n" "[Header]" to:out_file_human
		format "%\n" "Version:3500" to:out_file_human
		format "%\n" "RigName:Bip_" to:out_file_human
		format "%\n" "Frequency:1" to:out_file_human
		format "%\n" "[Data]" to:out_file_human
		format "%\n" "SceneRootNode.Hub=\"Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.ArbBone[0]=\"Camera\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.ArbBone[1]=\"CamTarget\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.ArbBone[2]=\"Root\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"Spine1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Chest\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0]=\"WeaponLeft\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0].ArbBone[0]=\"WeaponIKTargetR\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0].ArbBone[1]=\"WeaponIKTargetRMirror\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0]=\"Weapon\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[0]=\"WeaponBolt\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[1]=\"WeaponExtra1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[2]=\"WeaponExtra2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[3]=\"WeaponExtra3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[4]=\"WeaponOptics1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[5]=\"WeaponOptics2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[6]=\"WeaponTrigger\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[7]=\"WeaponIKTargetL\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[8]=\"WeaponIKTargetLMirror\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9]=\"WeaponMagazine\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[0]=\"WeaponMagazineChild1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[1]=\"WeaponMagazineChild2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[2]=\"WeaponMagazineChild3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[3]=\"WeaponMagazineChild4\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[4]=\"WeaponMagazineChild5\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_human
		close out_file_human
		print "true" 			
		)
)

fn create_mapping_file_ghoul = 
(
Environment_ghoul = dotNetClass "System.Environment"
temp_ghoul  = Environment_ghoul.GetEnvironmentVariable "temp"
	free out_path_ghoul
	out_path_ghoul = temp_ghoul +"\\HKXtoBIP_ghoul.cam"
	if out_path_ghoul != undefined then
		(
		print "---------------" 
		print "Create Mapping File "+ out_path_ghoul
	
		out_file_ghoul = createfile out_path_ghoul
			
		format "%\n" "[Header]" to:out_file_ghoul
		format "%\n" "Version:3500" to:out_file_ghoul
		format "%\n" "RigName:Bip_" to:out_file_ghoul
		format "%\n" "Frequency:1" to:out_file_ghoul
		format "%\n" "[Data]" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub=\"Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LThigh\" (matrix3 [0.998707,-0.033119,-0.0385556] [0.0205686,0.957022,-0.289287] [0.0464794,0.28812,0.956466] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LCalf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LFoot\" (matrix3 [0.972299,-0.233678,-0.00539169] [0.233728,0.972228,0.0119887] [0.00244044,-0.0129167,0.999914] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LToe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RThigh\" (matrix3 [0.999785,-0.0204171,-0.00365693] [0.0207117,0.973158,0.229203] [-0.00112089,-0.22923,0.973372] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RCalf\" (matrix3 [0.999745,-0.000272205,-0.022575] [0.00664322,0.959205,0.282632] [0.0215772,-0.28271,0.958963] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RFoot\" (matrix3 [0.959473,-0.281718,0.00686926] [0.28179,0.95937,-0.0142447] [-0.00257719,0.0156031,0.999875] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RToe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"SpineRoot\" (matrix3 [0.996729,0.0808122,0] [-0.0808122,0.996729,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine1\" (matrix3 [0.986939,0.161096,0] [-0.161096,0.986939,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Spine2\" (matrix3 [0.996729,0.0808124,0] [-0.0808122,0.99673,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LCollarbone\" (matrix3 [0.84691,0.47902,0.230831] [-0.492719,0.870186,0.00195749] [-0.199929,-0.115393,0.972992] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LUpperArm\" (matrix3 [0.999209,-0.0394851,0.00462876] [-0.037512,-0.89784,0.438721] [-0.0131675,-0.438548,-0.898612] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LForeArm1\" (matrix3 [0.998535,-0.0221422,0.0493774] [0.0515579,0.666427,-0.743786] [-0.0164374,0.745242,0.666592] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LHand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LThumb\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LThumb1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LThumb2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LIndex\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LIndex1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LIndex2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LMiddle\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LMiddle1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LMiddle2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LRing\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LRing1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LRing2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LPinky\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LPinky1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LPinky2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RCollarbone\" (matrix3 [0.840371,0.495526,-0.219616] [-0.516956,0.854549,-0.0500126] [0.16289,0.155561,0.974304] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RUpperArm\" (matrix3 [0.998169,-0.00877196,-0.059816] [-0.0235503,-0.967682,-0.25107] [-0.0556808,0.252019,-0.966118] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RForeArm1\" (matrix3 [0.985394,-0.117378,-0.123386] [0.154546,0.920698,0.358379] [0.0715345,-0.372212,0.925389] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RHand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RThumb\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RThumb1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RThumb2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RIndex\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RIndex1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RIndex2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RMiddle\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RMiddle1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RMiddle2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RRing\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RRing1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RRing2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RPinky\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RPinky1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RPinky2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_ghoul
		close out_file_ghoul
		print "true" 		
	)
)

fn create_mapping_file_supermutant = 
(	
	Environment_supermutant = dotNetClass "System.Environment"
	temp_supermutant  = Environment_supermutant.GetEnvironmentVariable "temp"
	free out_path_supermutant
	out_path_supermutant = temp_supermutant +"\\HKXtoBIP_supermutant.cam"
	if out_path_supermutant != undefined then
		(
		print "---------------" 
		print "Create Mapping File "+ out_path_supermutant
	
		out_file_supermutant = createfile out_path_supermutant

		format "%\n" "[Header]" to:out_file_supermutant
		format "%\n" "Version:3500" to:out_file_supermutant
		format "%\n" "RigName:Bip_" to:out_file_supermutant
		format "%\n" "Frequency:1" to:out_file_supermutant
		format "%\n" "[Data]" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub=\"Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [-20.4742,0,-1.83053e-005])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.ArbBone[2]=\"Root\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"Spine1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Chest\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0]=\"WeaponLeft\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0]=\"Weapon\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[0]=\"WeaponBolt\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[1]=\"WeaponExtra1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[2]=\"WeaponExtra2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[3]=\"WeaponExtra3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[4]=\"WeaponOptics1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[5]=\"WeaponOptics2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[6]=\"WeaponTrigger\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[7]=\"WeaponIKTargetL\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[8]=\"WeaponIKTargetR\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9]=\"WeaponMagazine\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[0]=\"WeaponMagazineChild1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[1]=\"WeaponMagazineChild2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[2]=\"WeaponMagazineChild3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[3]=\"WeaponMagazineChild4\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[4]=\"WeaponMagazineChild5\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_supermutant
		close out_file_supermutant
		print "true" 		
	)
)

fn create_mapping_file_fallout76 = 
(	
	Environment_fallout76 = dotNetClass "System.Environment"
	temp_fallout76  = Environment_fallout76.GetEnvironmentVariable "temp"
	free out_path_fallout76
	out_path_fallout76 = temp_fallout76 +"\\HKXtoBIP_fallout76.cam"
	if out_path_fallout76 != undefined then
		(
		print "---------------" 
		print "Create Mapping File "+ out_path_fallout76
	
		out_file_fallout76 = createfile out_path_fallout76
	
		format "%\n" "[Header]" to:out_file_fallout76
		format "%\n" "Version:3500" to:out_file_fallout76
		format "%\n" "RigName:Bip_" to:out_file_fallout76
		format "%\n" "Frequency:1" to:out_file_fallout76
		format "%\n" "[Data]" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub])Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.ArbBone[2]=\"Root\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"Spine1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Chest\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0]=\"WeaponLeft\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0]=\"Weapon\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[0]=\"WeaponBolt\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[1]=\"WeaponExtra1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[2]=\"WeaponExtra2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[3]=\"WeaponExtra3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[4]=\"WeaponOptics1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[5]=\"WeaponOptics2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[6]=\"WeaponTrigger\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9]=\"WeaponMagazine\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[0]=\"WeaponMagazineChild1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[1]=\"WeaponMagazineChild2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[2]=\"WeaponMagazineChild3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[3]=\"WeaponMagazineChild4\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[4]=\"WeaponMagazineChild5\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file_fallout76
	
			
		close out_file_fallout76
		print "true" 		
	)
)

fn free_globals = (
	
	free out_path_human
	free out_path_ghoul
	free out_path_supermutant
	free skel_human
	free skel_ghoul
	free skel_supermutant
	free skel_fallout76
	free allChildren
	free BtnState
	free RootSrc
	free userprops_human
	free userprops_ghoul
	free userprops_supermutant
	free userprops_fallout76
	free switch
)

fn startup_rigs = (
		
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
rollout hkxImporter "" width:171 height:166
(
	-----------------------------------------
	radiobuttons rdo1 "Select Source Race" pos:[12,42] width:87 height:78 enabled:true labels:#("Human", "Ghoul", "Super Mutant", "Fallout 76") default:0 columns:1
	button btnRun " Run" pos:[9,137] width:50 height:20 enabled:false
	label lbl1 "hkxImporter" pos:[57,5] width:62 height:16
	button btnClose " X" pos:[142,137] width:20 height:20
	button btn3 " ?" pos:[117,137] width:20 height:20
	button btnRefresh "Reset" pos:[62,137] width:50 height:20
	label lbl2 "for Fallout 4 by Sebbo" pos:[34,20] width:123 height:16

	fn start_function =
	(		
		if (classOf $Root) != BoneGeometry then 
		(
			if switch == 1 then (
			print "Creating Human->Human Mapping"
			create_mapping_file_human()
			free allChildren	
							if $Root != undefined do ( 			
								capture_animation $Bip_ $Root out_path_human
								change_names_back()
								print "---------------" 	
								print "Collect Children"
								rename_objects_substract allChildren 7 $Root_Source
								cleanup_layer()
								select $Bip_
							)
			)
			
			if switch == 2 then (
			print "Creating Ghoul->Human Mapping"
			create_mapping_file_ghoul()			
			free allChildren	
							if $Root != undefined do ( 			
								capture_animation $Bip_ $Root out_path_ghoul
								change_names_back()
								print "---------------" 	
								print "Collect Children"
								rename_objects_substract allChildren 7 $Root_Source
								cleanup_layer()
								select $Bip_
							)
				
			)
			
			if switch == 3 then 
			(
						print "Creating SuperMutant->Human Mapping"
						create_mapping_file_supermutant()
						free allChildren
							if $Root != undefined do 
							( 			
								capture_animation $Bip_ $Root out_path_supermutant
								change_names_back()
								print "---------------" 	
								print "Collect Children"
								rename_objects_substract allChildren 7 $Root_Source
								cleanup_layer()
								select $Bip_
							)
			)
					
			if switch == 4 then 
			(
						print "Creating Fallout 76->Human Mapping"
						create_mapping_file_fallout76()
						free allChildren
							if $Root != undefined do 
							( 			
								capture_animation $Bip_ $Root out_path_fallout76
								change_names_back()
								print "---------------" 	
								print "Collect Children"
				--			rename_objects_substract allChildren 7 $Root_Source
								
								cleanup_layer()
								select $Bip_
							)
			)
		)
	)

	
	on rdo1 changed state do
	(
		if $Bip_ != undefined do (
				btnRun.enabled = true
				switch = rdo1.state
			
						if switch == 1 and BtnState != 1 then (
							if BtnState == 2 then (
								rename_objects_addition allChildren "_ghoul"
							)
							if BtnState == 3 then (
								rename_objects_addition allChildren "_supermutant"
							)
							if BtnState == 4 then (
								rename_objects_addition allChildren "_fallout76"
							)
							
							rename_objects_substract allChildren 6 $Root_human
							BtnState = 1
						)
		
						if rdo1.state == 2 and BtnState != 2 then (
							switch = rdo1.state
							if BtnState == 1 then (
								rename_objects_addition allChildren "_human"
							)
							if BtnState == 3 then (
								rename_objects_addition allChildren "_supermutant"
							)
							if BtnState == 4 then (
								rename_objects_addition allChildren "_fallout76"
							)
							
							rename_objects_substract allChildren 6  $Root_ghoul
							BtnState = 2
						)
		
						if rdo1.state == 3 and BtnState != 3 then (
							switch = rdo1.state
							if BtnState == 1 then (
								rename_objects_addition allChildren "_human"
							)
							if BtnState == 2 then (
								rename_objects_addition allChildren "_ghoul"
							)
							if BtnState == 4 then (
								rename_objects_addition allChildren "_fallout76"
							)
						
							rename_objects_substract allChildren 12 $Root_supermutant
							BtnState = 3
						)
						
						if rdo1.state == 4 and BtnState != 4 then (
							switch = rdo1.state
							if BtnState == 1 then (
								rename_objects_addition allChildren "_human"
							)
							if BtnState == 2 then (
								rename_objects_addition allChildren "_ghoul"
							)
							if BtnState == 3 then (
								rename_objects_addition allChildren "_supermutant"
							)				
								rename_objects_substract allChildren 10  $Root_fallout76
								BtnState = 4
						)
		)
	)
	
	on btnRun pressed do
	(
					start_function()
	)
			
	on btnClose pressed do
	(
					destroyDialog hkxImporter
	)
	on btn3 pressed do
	(
				messageBox \
					"Help!\n\nFor the script to work make sure you have all the necessary prerequisite:\n\n-Havok Content Tools\n-Havok 3ds Max Plugin ( https://github.com/PredatorCZ/HavokMax/releases )\n-NIF_Exporter (for 3ds Max 2013 provided by Bethesda in \Fallout 4\Tools\NIF_Exporter folder. (For newer 3ds Max versions search on nexusmods)\n\nUsage:\n\n-Open the max file included with this script: F4BipedCAT_2013.max.\n-Run the script via MAXScript menu or via drag and drop into the view screen.\n-Select the source race\n-Import a *.hkx from 3ds Max main menu or if enabled in 3ds Max settings via drag and drop.\n-Make sure \"Invert Top\" is unchecked in the import menu.(The import menu only shows up if you import manualy, not drag and drop)\n-Press run on the script\n-Save the max file with a new filename and start editing.\n-If an animation is already loaded and you want to try another one, press the reset button before and set the source race.\n\n Created by Sebbo\n"\  
					title:"Help" beep:false		
				
	)
	on btnRefresh pressed do
	(
				destroyDialog hkxImporter
				loadMaxFile (maxFilePath + maxFileName) quiet:true
				fileIn(getThisScriptFilename()) 
	)
)
	if $Bip_ != undefined do ( 
	startup_rigs()	
	)
	createDialog hkxImporter