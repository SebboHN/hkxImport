-----------------------------------------------------------------------------
--		HKXImport / Mapping Script by Sebbo
-----------------------------------------------------------------------------

global out_path
global allChildren = #()

fn capture_animation catparentnode source_hierarchy_root camfile quiet:true delsrc:true StartTime:animationRange.start EndTime:animationRange.end layername:"" = 
(		
	print "---------------" 	
	print "Transfering Animation"
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
		print "true" 	
		return true;
	)
	wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
)

fn collect_children obj &allChildren includeParent:true includeHidden:true =
(
	-- check if object should be collected
	if (includeHidden or not obj.isHiddenInVpt) and includeParent and finditem allChildren obj == 0 then
		append allChildren obj

	-- collect current object's children
	for c in obj.children do collect_children c &allChildren includeParent:true includeHidden:includeHidden
	
)

fn rename_objects obj =
(
	print "true" 
	print "---------------" 	 	
	print "Object Renaming"
	select $Root_Source
	for obj in selection do collect_children obj &allChildren
	select allChildren

	for i=1 to obj.count do 
	(
		tokens = substring obj[i].name 1 (obj[i].name.count - 7)
		obj[i].name = tokens
	)
	print "true" 	
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

Environment = dotNetClass "System.Environment"
temp = Environment.GetEnvironmentVariable "temp"

	out_path = temp +"\\HKXtoBIP.cam"
	if out_path != undefined then
		(
		print "---------------" 
		print "Create Mapping File "+ out_path 	
	
		out_file = createfile out_path
		
		format "%\n" "[Header]" to:out_file
		format "%\n" "Version:3500" to:out_file
		format "%\n" "RigName:Bip_" to:out_file
		format "%\n" "Frequency:1" to:out_file
		format "%\n" "[Data]" to:out_file
		format "%\n" "SceneRootNode.Hub=\"Pelvis\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.ArbBone[0]=\"Camera\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.ArbBone[1]=\"CamTarget\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.ArbBone[2]=\"Root\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm=\"LLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RLeg_Thigh\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RLeg_Calf\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm=\"RLeg_Foot\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RLeg_Toe1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[0]=\"Spine1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].SpineLink[1]=\"Spine2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub=\"Chest\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone=\"LArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]=\"LArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]=\"LArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm=\"LArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0]=\"WeaponLeft\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0].ArbBone[0]=\"WeaponIKTargetR\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.ArbBone[0].ArbBone[1]=\"WeaponIKTargetRMirror\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]=\"LArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]=\"LArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]=\"LArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]=\"LArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]=\"LArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]=\"LArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]=\"LArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]=\"LArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]=\"LArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]=\"LArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]=\"LArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]=\"LArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]=\"LArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]=\"LArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]=\"LArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone=\"RArm_Collarbone\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]=\"RArm_UpperArm\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]=\"RArm_ForeArm1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm=\"RArm_Hand\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0]=\"Weapon\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[0]=\"WeaponBolt\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[1]=\"WeaponExtra1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[2]=\"WeaponExtra2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[3]=\"WeaponExtra3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[4]=\"WeaponOptics1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[5]=\"WeaponOptics2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[6]=\"WeaponTrigger\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[7]=\"WeaponIKTargetL\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[8]=\"WeaponIKTargetLMirror\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9]=\"WeaponMagazine\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[0]=\"WeaponMagazineChild1\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[1]=\"WeaponMagazineChild2\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[2]=\"WeaponMagazineChild3\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[3]=\"WeaponMagazineChild4\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.ArbBone[0].ArbBone[9].ArbBone[4]=\"WeaponMagazineChild5\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]=\"RArm_Finger11\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]=\"RArm_Finger12\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]=\"RArm_Finger13\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]=\"RArm_Finger21\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]=\"RArm_Finger22\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]=\"RArm_Finger23\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]=\"RArm_Finger31\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]=\"RArm_Finger32\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]=\"RArm_Finger33\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]=\"RArm_Finger41\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]=\"RArm_Finger42\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]=\"RArm_Finger43\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]=\"RArm_Finger51\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]=\"RArm_Finger52\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]=\"RArm_Finger53\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]=\"Neck\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		format "%\n" "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub=\"Head\" (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])" to:out_file
		close out_file
		print "true" 			
		)
)

	fn start_function =
	(
		if (classOf $Root) != BoneGeometry do (
			create_mapping_file_human()
		
		if $Root != undefined do ( 			
		capture_animation $Bip_ $Root out_path
		print "---------------" 	
		print "Collect Children"
		rename_objects allChildren
		cleanup_layer()
		select $Bip_
		)
	)
)
start_function()
