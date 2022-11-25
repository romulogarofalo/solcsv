ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Solcsv.Repo, :manual)

Hammox.defmock(SolcsvAdapters.ViacepAdapterMock, for: Solcsv.Ports.Viacep)
Hammox.defmock(TeslaMock, for: Tesla.Adapter)
