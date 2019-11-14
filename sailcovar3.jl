using JuMP, Clp, Printf

d = [40 60 75 25]                      # Each quarter demands for boats.

m = Model(with_optimizer(Clp.Optimizer))

################  VARIABLES ################

@variable(m, 0 <= x[1:4] <= 40)       # Boats produced with regular labor.
@variable(m, y[1:4] >= 0)             # Boats produced with overtime labor.
#@variable(m, h[1:5])                 # Boats held in inventory.
@variable(m, hinc[1:5] >= 0)          # h+ Boats held in inventory.
@variable(m, hdec[1:5] >= 0)          # h- Boats held in inventory.
@variable(m, cinc[1:4] >= 0)
@variable(m, cdec[1:4] >= 0)

###############  CONSTRAINTS ###############

#@constraint(m, x[0] == 40)           # 50 boats made during the Q preceding Q1.
#@constraint(m, y[0] == 10)
@constraint(m, hinc[4] >= 10)         # h+ should be greater than 10
@constraint(m, hdec[4] <= 0)          # h- should be smaller than 0
@constraint(m, hinc[1]-hdec[1] ==  (10)+x[1]+y[1]-d[1])
@constraint(m, x[1]+y[1]-(50) == cinc[1]-cdec[1])
@constraint(m, flow[i in 1:3], (hinc[i+1] - hdec[i+1]) == (hinc[i] - hdec[i]) + x[i+1]+y[i+1]-d[i+1])
@constraint(m, stream[i in 1:3], x[i+1]+y[i+1]-(x[i]+y[i]) == cinc[i+1]-cdec[i+1])

###############  OBJECTIVE #################

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(hinc) + 100*sum(hdec) + 400*sum(cinc) + 500*sum(cdec))           # Formula of minimize costs.

optimize!(m)

@printf("\n")
@printf("Expected demand for each four quarter in oneyear : %d %d %d %d\n",(d[1]), (d[2]), (d[3]), (d[4]))
@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
#@printf("Inventories: %d %d %d %d %d\n", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("H+ values: %d %d %d %d %d\n", value(hinc[1]), value(hinc[2]), value(hinc[3]), value(hinc[4]), value(hinc[5]))
@printf("H- values: %d %d %d %d %d\n", value(hdec[1]), value(hdec[2]), value(hdec[3]), value(hdec[4]), value(hdec[5]))
#@printf("C+ values: %d %d %d %d\n", value(cinc[1]), value(cinc[2]), value(cinc[3]), value(cinc[4]))        # All of them are zero
#@printf("C- values: %d %d %d %d\n", value(cdec[1]), value(cdec[2]), value(cdec[3]), value(cdec[4]))        # All of them are zero
@printf("Objective cost: %f\n", objective_value(m))
