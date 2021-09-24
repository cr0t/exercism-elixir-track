defmodule TopSecretTest do
  use ExUnit.Case

  describe "to_ast/1" do
    @tag task_id: 1
    test "handles an empty string" do
      string = ""
      ast = {:__block__, [], []}

      assert TopSecret.to_ast(string) == ast
    end

    @tag task_id: 1
    test "handles a small code snippet" do
      string = """
      x = 7
      y = x - 2
      """

      ast =
        {:__block__, [],
         [
           {:=, [line: 1], [{:x, [line: 1], nil}, 7]},
           {:=, [line: 2], [{:y, [line: 2], nil}, {:-, [line: 2], [{:x, [line: 2], nil}, 2]}]}
         ]}

      assert TopSecret.to_ast(string) == ast
    end

    @tag task_id: 1
    test "handles a bigger code snippet" do
      string = """
      defmodule List do
        @spec delete([], any) :: []
        @spec delete([...], any) :: list
        def delete(list, element)
      end
      """

      ast = {
        :defmodule,
        [line: 1],
        [
          {:__aliases__, [line: 1], [:List]},
          [
            do: {
              :__block__,
              [],
              [
                {:@, [line: 2],
                 [
                   {:spec, [line: 2],
                    [{:"::", [line: 2], [{:delete, [line: 2], [[], {:any, [line: 2], nil}]}, []]}]}
                 ]},
                {:@, [line: 3],
                 [
                   {:spec, [line: 3],
                    [
                      {:"::", [line: 3],
                       [
                         {:delete, [line: 3], [[{:..., [line: 3], nil}], {:any, [line: 3], nil}]},
                         {:list, [line: 3], nil}
                       ]}
                    ]}
                 ]},
                {:def, [line: 4],
                 [{:delete, [line: 4], [{:list, [line: 4], nil}, {:element, [line: 4], nil}]}]}
              ]
            }
          ]
        ]
      }

      assert TopSecret.to_ast(string) == ast
    end
  end

  describe "decode_secret_message/1" do
    @tag task_id: 3
    test "decodes a secret message" do
      code = """
        defmodule TotallyNotTopSecret do
          def force(mass, acceleration), do: mass * acceleration
          def uniform(from, to), do: rand.uniform(to - from) + from
          def data(%{metadata: metadata}), do: model(metadata)
          defp model(metadata), do: metadata |> less_data |> Enum.reverse() |> Enum.take(3)
          defp less_data(data), do: Enum.reject(data, &is_nil/1)
        end
      """

      secret_message = "foundamole"

      assert TopSecret.decode_secret_message(code) == secret_message
    end
  end
end
