defmodule Utils.Math do
  alias :math, as: Math

  @shapes_indexes %{
    rectangle: 0,
    circle: 1
  }

  def shape_index(shape_atom) do
    @shapes_indexes[shape_atom]
  end

  def collision?(
        rect1_x,
        rect1_y,
        {:rectangle, rect1_width},
        rect2_x,
        rect2_y,
        {:rectangle, rect2_width}
      ) do
    rect1_height = rect1_width
    rect2_height = rect1_width

    rect1_x < rect2_x + rect2_width and
      rect1_x + rect1_width > rect2_x and
      rect1_y < rect2_y + rect2_height and
      rect1_y + rect1_height > rect2_y
  end

  def collision?(
        circle1_x,
        circle1_y,
        {:circle, circle1_diameter},
        circle2_x,
        circle2_y,
        {:circle, circle2_diameter}
      ) do
    collision_circle_with_circle?(
      circle1_x,
      circle1_y,
      circle1_diameter,
      circle2_x,
      circle2_y,
      circle2_diameter
    )
  end

  def collision?(
        rect_x,
        rect_y,
        {:rectangle, _rect_width} = rect,
        circle_x,
        circle_y,
        {:circle, _circle_diameter} = circle
      ) do
    collision?(
      circle_x,
      circle_y,
      circle,
      rect_x,
      rect_y,
      rect
    )
  end

  def collision?(
        circle_x,
        circle_y,
        {:circle, circle_diameter},
        rect_x,
        rect_y,
        {:rectangle, rect_width}
      ) do
    collision_circle_with_rectangle?(
      circle_x,
      circle_y,
      circle_diameter,
      rect_x,
      rect_y,
      rect_width,
      rect_width
    )
  end

  def distance(ax, ay, bx, by) do
    Math.sqrt(Math.pow(ax - bx, 2) + Math.pow(ay - by, 2))
  end

  defp collision_circle_with_circle?(ax, ay, adiam, bx, by, bdiam) do
    distance(ax, ay, bx, by) < adiam / 2 + bdiam / 2
  end

  defp collision_circle_with_rectangle?(
         circle_x,
         circle_y,
         circle_diameter,
         rect_x,
         rect_y,
         rect_width,
         rect_height
       ) do
    point_in_rectangle?(circle_x, circle_y, rect_x, rect_y, rect_width, rect_height) or
      line_intersects_circle?(
        rect_x,
        rect_y,
        rect_x + rect_height,
        rect_y,
        circle_x,
        circle_y,
        circle_diameter
      ) or
      line_intersects_circle?(
        rect_x + rect_height,
        rect_y,
        rect_x + rect_height,
        rect_y + rect_width,
        circle_x,
        circle_y,
        circle_diameter
      ) or
      line_intersects_circle?(
        rect_x + rect_height,
        rect_y + rect_width,
        rect_x,
        rect_y + rect_width,
        circle_x,
        circle_y,
        circle_diameter
      ) or
      line_intersects_circle?(
        rect_x,
        rect_y + rect_width,
        rect_x,
        rect_y,
        circle_x,
        circle_y,
        circle_diameter
      )
  end

  defp point_in_rectangle?(x, y, rect_x, rect_y, rect_w, rect_h) do
    x >= rect_x and x <= rect_x + rect_h and
      (y >= rect_y and x <= rect_x + rect_w)
  end

  # https://math.stackexchange.com/questions/275529/check-if-line-intersects-with-circles-perimeter
  defp line_intersects_circle?(x1, y1, x2, y2, circle_x, circle_y, circle_diameter) do
    ax = x1
    ay = y1
    bx = x2
    by = y2
    cx = circle_x
    cy = circle_y
    r = circle_diameter / 2

    # parameters: ax ay bx by cx cy r
    ax = ax - cx
    ay = ay - cy
    bx = bx - cx
    by = by - cy
    a = Math.pow(bx - ax, 2) + Math.pow(by - ay, 2)
    b = 2 * (ax * (bx - ax) + ay * (by - ay))

    c = Math.pow(ax, 2) + Math.pow(ay, 2) - Math.pow(r, 2)
    disc = Math.pow(b, 2) - 4 * a * c

    if disc <= 0 do
      false
    else
      sqrtdisc = Math.sqrt(disc)
      t1 = (-b + sqrtdisc) / (2 * a)
      t2 = (-b - sqrtdisc) / (2 * a)

      if (0 < t1 && t1 < 1) || (0 < t2 && t2 < 1) do
        true
      else
        false
      end
    end
  end
end
