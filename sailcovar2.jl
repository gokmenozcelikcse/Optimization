using JuMP, Clp, Printf

d = [40 60 75 25]                      # Each quarter demands for boats.

m = Model(with_optimizer(Clp.Optimizer))

################  VARIABLES ################

@variable(m, 0 <= x[0:4] <= 40)       # Boats produced with regular labor.
@variable(m, y[0:4] >= 0)             # Boats produced with overtime labor.
@variable(m, h[1:5] >= 0)             # Boats held in inventory.
@variable(m, cinc[1:5] >= 0)
@variable(m, cdec[1:5] >= 0)

###############  CONSTRAINTS ###############

@constraint(m, x[0] == 40)            # 50 boats made during the Q preceding Q1.
@constraint(m, y[0] == 10)
@constraint(m, h[5] >= 10)            # Boats held in inventory after last quarter.
@constraint(m, h[1] == 10)            # 10 Boats held in inventory.
@constraint(m, flow[i in 1:4], h[i]+x[i]+y[i]-d[i]==h[i+1])     # Conservation of boats.
@constraint(m, stream[i in 0:3], x[i+1]+y[i+1]-(x[i]+y[i])==cinc[i+1]-cdec[i+1])

###############  OBJECTIVE #################

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) + 400*sum(cinc) + 500*sum(cdec))         # Formula of minimize costs.

optimize!(m)

@printf("\n")
@printf("Expected demand for each four quarter in oneyear : %d %d %d %d\n",(d[1]), (d[2]), (d[3]), (d[4]))
@printf("Boats to build regular labor: %d %d %d %d %d\n", value(x[0]), value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d %d\n", value(y[0]), value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d\n", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("C+ values: %d %d %d %d %d\n", value(cinc[1]), value(cinc[2]), value(cinc[3]), value(cinc[4]), value(cinc[5]))
#@printf("C- values: %d %d %d %d %d\n", value(cdec[1]), value(cdec[2]), value(cdec[3]), value(cdec[4]), value(cdec[5]))       # All of them are zero
@printf("Objective cost: %f\n", objective_value(m))
