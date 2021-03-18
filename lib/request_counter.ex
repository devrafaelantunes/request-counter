defmodule RequestCounter do
    use GenServer

    @name Requests
    @limite 5

    # GenServer

    def start_link(_) do
        GenServer.start_link(RequestCounter, :ok, name: @name)
    end

    def init(:ok) do
        {:ok, %{}}
    end

    def new(input) do
        ip = input.ip
        |> to_charlist() 
        |> :inet.parse_address()
        |> case do
            {:ok, result} -> GenServer.call(@name, {:upsert, input})
            {:error, reason} -> {:error, :ip_is_not_valid}
        end
    end

    def get(ip) do 
        GenServer.call(@name, {:get_request_count, ip})
    end


    def handle_call({:upsert, input}, _from, state) do

        ip = input.ip # input é um mapa e q tem uma chave ip, quero o valor do ip, se ip nao existir vai dar exception

        {reply, new_state} = 
            if Map.get(state, ip, 0) >= @limite do
                {{:error, :limit_reached}, state}
            else
                {:ok, update_or_insert(state, ip)}
            end
    
        {:reply, reply, new_state}

        end

    def handle_call({:get_request_count, ip}, _from, state) do
        count = Map.get(state, ip, 0)
        {:reply, count, state}
    end

    # GenServer

    # Lógica

    defp update_or_insert(state, ip) do
        old_value = Map.get(state, ip, 0)
        Map.put(state, ip, old_value + 1)
    end

    # Lógica

end


# 1) tá faltando teste pra saber se o RQ tá atingindo aquele limite que vc setou de 5 requests

# 3) escreva uma função chamada get_top(n) que retorna os N ips com mais requests

# Suponha que ip A tem 100 requests, ip b tem 50 e IP c tem 10. Eu chamo get_top(2). Tem que me retornar uma lista, na ordem decrescente, com uma tupla contendo o IP e o total de requests. Então nesse caso ela retornaria [{a, 100}, {b, 50}].

# Escreva testes mostrando que o gettop funciona