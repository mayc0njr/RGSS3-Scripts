#==============================================================================
# Conspiracy Auto Save
#==============================================================================
# Author : Maycon "Conspiracy"
# Version : 0.2
#==============================================================================

#==============================================================================
# To use:
#   Use a Script Call for: Auto_Save.start
#==============================================================================

#==============================================================================
# What this does:
#   Save the game without any prompt or the Scene_Save itself
#   The save goes to the loaded slot, overwritting it.
#==============================================================================

#==============================================================================
# Module Auto_Save
# Config Variable
#==============================================================================

module Auto_Save
  Var_Auto = 79 # Game Variable that'll store the save slot.
  #============================================================================
  # ● Call this function to (auto)save the game.
  #============================================================================
  def self.start
    if $game_variables[Var_Auto] < 0
      SceneManager.call(Scene_Save)
    else
      SceneManager.goto(Scene_AutoSave)
      SceneManager.snapshot_without_blur
    end
  end
end

#==============================================================================
# Scene_Save
#------------------------------------------------------------------------------
# Modificated to save the game and store the saved slot on a variable.
#==============================================================================

class Scene_Save < Scene_File
  include Auto_Save
  alias old_save_success on_save_success
  #============================================================================
  # ● Save the game and store the save index.
  #============================================================================
  def on_save_success
    if SceneManager.scene_is?(Scene_Save)
      old_save_success
    end
    $game_variables[Var_Auto] = @index
  end
  
  #============================================================================
  # ● Manually set the save index passing a value.
  #============================================================================
  def set_index(value)
    @index = value
  end
end

#==============================================================================
# Scene_Load
#------------------------------------------------------------------------------
# Modificated to load the game and store the loaded slot on a variable.
#==============================================================================

class Scene_Load < Scene_File
  include Auto_Save
  alias old_load_success on_load_success
  
  #============================================================================
  # ● Load the game and store the load index.
  #============================================================================
  def on_load_success
    if SceneManager.scene_is?(Scene_Load)
      old_load_success
    end
    $game_variables[Var_Auto] = @index
  end
end

#==============================================================================
# SceneManager
#------------------------------------------------------------------------------
# Modificated to store the Last_Scene when use SceneManager.goto.
#==============================================================================

module SceneManager
  
  @bg_bmp = nil
  
  class << self
    alias old_goto goto
  end
  
  #============================================================================
  # ● Go to the specified Scene and stores the previous on a variable.
  #============================================================================
  def self.goto(scene_class)
    @last_scene = @scene if @scene.class.name.start_with?("Scene") && !@scene.instance_of?(scene_class)
    self.old_goto(scene_class)
  end
  
  #============================================================================
  # ● Returns the class of previous Scene.
  #============================================================================
  def self.last_scene
    return @last_scene.class
  end
  
  #============================================================================
  # ● Take a snap of the map without the blur effect.
  #============================================================================
  def self.snapshot_without_blur
    @bg_bmp.dispose if @bg_bmp
    @bg_bmp = Graphics.snap_to_bitmap
  end
  
  #============================================================================
  # ● Returns the @bg_bmp var.
  #============================================================================
  def self.bg_bmp
    @bg_bmp
  end
  
end

#==============================================================================
# Scene_AutoSave
#------------------------------------------------------------------------------
# Go to this Scene to (auto)save your game.
#==============================================================================

class Scene_AutoSave < Scene_MenuBase
  include Auto_Save
  
  #============================================================================
  # ● Store the previous Scene and saves the game.
  #============================================================================
  def start
    super
    @last_scene = SceneManager.last_scene
    teste = Scene_Save.new
    teste.set_index($game_variables[Var_Auto])
    teste.on_savefile_ok
  end
  
  #============================================================================
  # ● Calls the terminate function.
  #============================================================================
  def update
    super
    terminate
  end
  
  #============================================================================
  # ● Terminate the Scene and calls the previous.
  #============================================================================
  def terminate
    super
    SceneManager.goto(@last_scene)
  end
  
  #============================================================================
  # ● Create a background of the map.
  #============================================================================
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.bg_bmp
  end

end

#==============================================================================
# Scene_AutoSave
#------------------------------------------------------------------------------
# Modificated to add a screenshot of the map without the blur effect
#==============================================================================

class Scene_Map < Scene_Base
  alias old_terminate terminate
  #============================================================================
  # ● Snap the map with and without the blur effect.
  #============================================================================
  def terminate
    SceneManager.snapshot_without_blur
    old_terminate
  end
end
