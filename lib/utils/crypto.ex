defmodule Utils.Crypto do
  @big_int 2_147_483_647

  def random_id do
    Integer.to_string(:rand.uniform(4_294_967_296), 32) <>
      Integer.to_string(:rand.uniform(4_294_967_296), 32)
  end

  def random do
    :rand.uniform(@big_int) / @big_int
  end
end
