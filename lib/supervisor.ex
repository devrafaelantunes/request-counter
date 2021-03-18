defmodule RequestSupervisor do
    use Application
    use Supervisor

    @namesupervisor RequestSuper

    @impl true
    def start(_type, _args) do
        Supervisor.start_link(__MODULE__, [], name: @namesupervisor)
    end

    @impl true
    def init(_) do
        children = [
            {RequestCounter, %{}}
        ]

        Supervisor.init(children, strategy: :one_for_one)
    end

end




