extends Control

# The width and height of each item.
export var item_size = 64
# Our mock inventory has 20 items out of a possible 100.
export var item_count = 20
export var column_count = 6 setget set_column_count, get_column_count
const max_slots = 100

# Notes:
#
# - Set rect_min_size on the child of a ScrollContainer to affect its size.
#   When either the width or height (or both) are bigger than that of
#   the ScrollContainer itself, that dimension will get a scroll bar.
# - We disable horizontal scrolling via the editor since we don't need it.
#   In doing so, we also avoid this bug: https://github.com/godotengine/godot/issues/28464
#   Set horizontal_scroll_enabled if doing it through code.
# - In the editor, under Size Flags, we check the "Expand" checkbox
#   in the "Horizontal" section. This makes the grid take up all of the available
#   space within the ScrollContainer.
# - The natural width (rect_min_size.x) of the grid is column_count * item_size.

func _ready():
    resize_grid()
    update_slots()

func scroll_bar_width():
    return get_parent_control().get_v_scrollbar().rect_size.x

func get_column_count():
    return column_count
    
func set_column_count(count):
    column_count = count
    resize_grid()
    update_slots()

func get_row_count():
    # Make sure we cast the result to an int, otherwise we have extra, unused vertical space
    # at the bottom of the grid.
    return int(max_slots / get_column_count())

func resize_grid():
    rect_min_size.x = get_column_count() * item_size
    rect_min_size.y = get_row_count() * item_size

func index_to_pos(index):
    var columns = get_column_count()
    return Vector2(int(index % columns), int(index / columns))
    
func update_slots():
    var rows = get_row_count()
    var columns = get_column_count()
    print("displaying " + str(rows) + " rows and " + str(columns) + " columns")
    
    for slot_index in range(0, max_slots):
        if get_child_count() - 1 < slot_index:
            # No slot here yet; need to create it.
            var grid_item = preload("res://InventoryGridSlot.tscn").instance()
            grid_item.rect_position = index_to_pos(slot_index) * item_size
            add_child(grid_item)
            
        var grid_item = get_child(slot_index)
        if (item_count > slot_index):
            # This slot is occupied.
            grid_item.texture = load("res://icon.png")
        else:
            grid_item.texture = load("res://slot.png")
        
func _input(event):
    if event.is_action("give_item") and event.is_pressed():
        # Give a row of items to make testing quicker.
        item_count += get_column_count()
        update_slots()
    elif event is InputEventMouseButton and !event.is_pressed():
        # While not necessary in this particular example,
        # if ScrollContainer is moved within e.g. a popup,
        # the event coordinates seem to be made global,
        # so it's a good idea to ensure that they are always local.
        var mouse_pos = make_input_local(event).position
        var item_column = mouse_pos.x / item_size
        if (item_column >= get_column_count()):
            # The click is outside of us.
            return
            
        var item_row = mouse_pos.y / item_size
        if (item_row >= get_row_count()):
            # The click is outside of us.
            return
        
        var item_index = int(item_row) * get_column_count() + int(item_column)
        if (event.button_index == BUTTON_LEFT):
            item_left_clicked(item_index)
        elif (event.button_index == BUTTON_RIGHT):
            item_right_clicked(item_index)
            
func item_left_clicked(index):
    print("item at index " + str(index) + " was left clicked")
    
func item_right_clicked(index):
    print("item at index " + str(index) + " was right clicked")