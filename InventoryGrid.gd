extends Control

# The width and height of each item.
export var item_size = 64
# Pretend that our inventory has 100 items.
export var item_count = 100

# Notes:
# - Set rect_min_size on the child of a ScrollContainer to affect its size.
#   When either the width or height (or both) are bigger than that of
#   the ScrollContainer itself, that dimension will get a scroll bar.
# - We disable horizontal scrolling via the editor since we don't need it.
#   In doing so, we also avoid this bug: https://github.com/godotengine/godot/issues/28464
#   Set horizontal_scroll_enabled if doing it through code.

func _ready():
    resize_grid()
    fill_grid()

func scroll_bar_width():
    return get_parent_control().get_v_scrollbar().rect_size.x

func column_count():
    # Calculate the number of columns based on our width and the size of each item.
    return int(rect_min_size.x / item_size)
    
func row_count():
    # The parent (ScrollContainer) determines our width, but we choose our height.
    # Make sure we cast the result to an int, otherwise we have extra, unused vertical space
    # at the bottom of the grid.
    return int(item_count / column_count())

func resize_grid():
    # We don't care how wide we are; that's up to our parent.
    # However, the parent needs to ensure that its width is a multiple of item_size,
    # because otherwise there will be extra, unused space on the right-hand side.
    # For example, if item_size is 64 and we want to display 6 columns,
    # the ScrollContainer's width should be 384.
    rect_min_size.x = get_parent_control().rect_size.x
    # We do control our height, though.
    rect_min_size.y = row_count() * item_size

func fill_grid():
    # Clear existing items.
    while (get_child_count() > 0):
        remove_child(get_child(0))
    
    var rows = row_count()
    var columns = column_count()
    print("displaying " + str(rows) + " rows and " + str(columns) + " columns")
    
    for y in range(0, rows):
        for x in range(0, columns):
            var grid_item = preload("res://InventoryGridItem.tscn").instance()
            grid_item.rect_position = Vector2(x * item_size, y * item_size)
            add_child(grid_item)
        
func _gui_input(event):
    if event is InputEventMouseButton and !event.is_pressed():
        var item_column = event.position.x / item_size
        if (item_column >= column_count()):
            # The click is outside of us (can happen when the parent's width
            # is not a multiple of item_size, for example).
            return
            
        var item_row = event.position.y / item_size
        if (item_row >= row_count()):
            # Should probably never happen since we set our own (perfect) height,
            # but just to be safe..
            return
        
        var item_index = int(item_row) * column_count() + int(item_column)
        if (event.button_index == BUTTON_LEFT):
            item_left_clicked(item_index)
        elif (event.button_index == BUTTON_RIGHT):
            item_right_clicked(item_index)
            
func item_left_clicked(index):
    print("item at index " + str(index) + " was left clicked")
    
func item_right_clicked(index):
    print("item at index " + str(index) + " was right clicked")