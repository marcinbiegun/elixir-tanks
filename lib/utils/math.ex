defmodule Utils.Math do
  alias :math, as: Math

  def distance(ax, ay, bx, by) do
    Math.sqrt(Math.pow(ax - bx, 2) + Math.pow(ay - by, 2))
  end

  def collision_circle_with_rectangle?(
        circle_x,
        circle_y,
        circle_diagonal,
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
        circle_diagonal
      ) or
      line_intersects_circle?(
        rect_x + rect_height,
        rect_y,
        rect_x + rect_height,
        rect_y + rect_width,
        circle_x,
        circle_y,
        circle_diagonal
      ) or
      line_intersects_circle?(
        rect_x + rect_height,
        rect_y + rect_width,
        rect_x,
        rect_y + rect_width,
        circle_x,
        circle_y,
        circle_diagonal
      ) or
      line_intersects_circle?(
        rect_x,
        rect_y + rect_width,
        rect_x,
        rect_y,
        circle_x,
        circle_y,
        circle_diagonal
      )
  end

  def point_in_rectangle?(x, y, rect_x, rect_y, rect_w, rect_h) do
    x >= rect_x and x <= rect_x + rect_h and
      (y >= rect_y and x <= rect_x + rect_w)
  end

  # https://math.stackexchange.com/questions/275529/check-if-line-intersects-with-circles-perimeter
  def line_intersects_circle?(x1, y1, x2, y2, circle_x, circle_y, circle_diagonal) do
    ax = x1
    ay = y1
    bx = x2
    by = y2
    cx = circle_x
    cy = circle_y
    r = circle_diagonal / 2

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
