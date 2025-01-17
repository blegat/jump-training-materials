# Copyright (c) 2019 Arpit Bhatia and contributors                               #src
#                                                                                #src
# Permission is hereby granted, free of charge, to any person obtaining a copy   #src
# of this software and associated documentation files (the "Software"), to deal  #src
# in the Software without restriction, including without limitation the rights   #src
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #src
# copies of the Software, and to permit persons to whom the Software is          #src
# furnished to do so, subject to the following conditions:                       #src
#                                                                                #src
# The above copyright notice and this permission notice shall be included in all #src
# copies or substantial portions of the Software.                                #src
#                                                                                #src
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #src
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #src
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #src
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #src
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #src
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #src
# SOFTWARE.                                                                      #src

# # Getting started with JuMP

# This tutorial is aimed at providing a quick introduction to writing JuMP code.

# ## What is JuMP?

# JuMP ("Julia for Mathematical Programming") is an open-source modeling
# language that is embedded in Julia. It allows users to users formulate various
# classes of optimization problems (linear, mixed-integer, quadratic, conic
# quadratic, semidefinite, and nonlinear) with easy-to-read code. These problems
# can then be solved using state-of-the-art open-source and commercial solvers.

# JuMP also makes advanced optimization techniques easily accessible from a
# high-level language.

# ## Installation

# JuMP is a package for Julia. From Julia, JuMP is installed by using the
# built-in package manager.

# ```julia
# import Pkg
# Pkg.add("JuMP")
# ```

# You also need to include a Julia package which provides an appropriate solver.
# One such solver is `GLPK.Optimizer`, which is provided by the
# [GLPK.jl package](https://github.com/JuliaOpt/GLPK.jl).
# ```julia
# import Pkg
# Pkg.add("GLPK")
# ```
# See [Installation Guide](@ref) for a list of other solvers you can use.

# ## An example

# Let's try to solve the following linear programming problem by using JuMP and
# GLPK. We will first look at the complete code to solve the problem and then go
# through it step by step.

# ```math
# \begin{aligned}
# & \min & 12x + 20y \\
# & \;\;\text{s.t.} & 6x + 8y \geq 100 \\
# & & 7x + 12y \geq 120 \\
# & & x \geq 0 \\
# & & y \in [0, 3] \\
# \end{aligned}
# ```

using JuMP
using GLPK
model = Model(GLPK.Optimizer)
@variable(model, x >= 0)
@variable(model, 0 <= y <= 3)
@objective(model, Min, 12x + 20y)
@constraint(model, c1, 6x + 8y >= 100)
@constraint(model, c2, 7x + 12y >= 120)
print(model)
optimize!(model)
@show termination_status(model)
@show primal_status(model)
@show dual_status(model)
@show objective_value(model)
@show value(x)
@show value(y)
@show shadow_price(c1)
@show shadow_price(c2)

# ## Step-by-step

# Once JuMP is installed, to use JuMP in your programs, we just need to write:

using JuMP

# We also need to include a Julia package which provides an appropriate solver.
# We want to use `GLPK.Optimizer` here which is provided by the `GLPK.jl`
# package.

using GLPK

# A model object is a container for variables, constraints, solver options, etc.
# Models are created with the [`Model`](@ref) function. The model can be created
# with an optimizer attached with default arguments by calling the constructor
# with the optimizer type, as follows:

model = Model(GLPK.Optimizer)

# Variables are modeled using [`@variable`](@ref):

@variable(model, x >= 0)

# They can have lower and upper bounds.

@variable(model, 0 <= y <= 30)

# The objective is set using [`@objective`](@ref):

@objective(model, Min, 12x + 20y)

# Constraints are modeled using [`@constraint`](@ref). Here `c1` and `c2` are
# the names of our constraint.

@constraint(model, c1, 6x + 8y >= 100)

#-

@constraint(model, c2, 7x + 12y >= 120)

#- Call `print` to display the model:

print(model)

# To solve the optimization problem, call the [`optimize!`] function.

optimize!(model)

# !!! info
#     The `!` after optimize is just part of the name. It's nothing special.
#     Julia has a convention that functions which mutate their arguments should
#     end in `!`. A common example is `push!`.

# Now let's see what information we can query about the solution.

# [`termination_status`](@ref) tells us why the solver stopped:

termination_status(model)

# In this case, the solver found an optimal solution. We should also check
# [`primal_status`](@ref) to see if the solver found a primal feasible point:

primal_status(model)

# and [`dual_status`](@ref) to see if the solver found a dual feasible point:

dual_status(model)

# Now we know that our solver found an optimal solution, and has a primal and a
# dual solution to query.

# Query the objective value using [`objective_value`](@ref):

objective_value(model)

# The primal solution using [`value`](@ref):

value(x)

#-

value(y)

# and the dual solution using [`shadow_price`](@ref):

shadow_price(c1)

#-

shadow_price(c2)

# ## Variable basics

model = Model()


# ### Variable bounds

# All of the variables we have created till now have had a bound. We can also
# create a free variable.

@variable(model, free_x)

# While creating a variable, instead of using the <= and >= syntax, we can also
# use the `lower_bound` and `upper_bound` keyword arguments.

@variable(model, keyword_x, lower_bound = 1, upper_bound = 2)

# We can query whether a variable has a bound using the `has_lower_bound` and
# `has_upper_bound` functions. The values of the bound can be obtained using the
# `lower_bound` and `upper_bound` functions.

has_upper_bound(keyword_x)

#-

upper_bound(keyword_x)

# Note querying the value of a bound that does not exist will result in an error.

lower_bound(free_x)

# JuMP also allows us to change the bounds on variable. We will learn this in
# the problem modification tutorial.

# ### [Containers](@id tutorial_variable_container)

# We have already seen how to add a single variable to a model using the
# [`@variable`](@ref) macro. Let's now look at more ways to add variables to a
# JuMP model.

# JuMP provides data structures for adding collections of variables to a model.
# These data structures are referred to as Containers and are of three types:
# `Arrays`, `DenseAxisArrays`, and `SparseAxisArrays`.

# #### Arrays

# JuMP arrays are created in a similar syntax to Julia arrays with the addition
# of specifying that the indices start with 1. If we do not tell JuMP that the
# indices start at 1, it will create a `DenseAxisArray` instead.

@variable(model, a[1:2, 1:2])

# An n-dimensional variable $x \in {R}^n$ having a bound $l \preceq x \preceq u$
# ($l, u \in {R}^n$) is added in the following manner.

n = 10
l = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10]
u = [10; 11; 12; 13; 14; 15; 16; 17; 18; 19]

@variable(model, l[i] <= x[i = 1:n] <= u[i])

# Note that while working with Containers, we can also create variable bounds
# depending upon the indices:

@variable(model, y[i = 1:2, j = 1:2] >= 2i + j)

# #### DenseAxisArrays

# `DenseAxisArrays` are used when the required indices are not one-based integer
# ranges. The syntax is similar except with an arbitrary vector as an index as
# opposed to a one-based range.

# An example where the indices are integers but do not start with one.

@variable(model, z[i = 2:3, j = 1:2:3] >= 0)

# Another example where the indices are an arbitrary vector.

@variable(model, w[1:5, ["red", "blue"]] <= 1)

# #### SparseAxisArrays

# `SparseAxisArrays` are created when the indices do not form a rectangular set.
# For example, this applies when indices have a dependence upon previous indices
# (called triangular indexing).

@variable(model, u[i = 1:3, j = i:5])

# We can also conditionally create variables by adding a comparison check that
# depends upon the named indices and is separated from the indices by a
# semi-colon (;).

@variable(model, v[i = 1:9; mod(i, 3) == 0])

# ### Variable types

# The last argument to the `@variable` macro is usually the variable type. Here
# we'll look at how to specify the variable type.

# #### Integer variables

# Integer optimization variables are constrained to the set $x \in {Z}$

@variable(model, integer_x, Int)

# or

@variable(model, integer_z, integer = true)

# #### Binary variables

# Binary optimization variables are constrained to the set $x \in \{0, 1\}$.

@variable(model, binary_x, Bin)

# or

@variable(model, binary_z, binary = true)

# ## Constraint basics

model = Model()
@variable(model, x)
@variable(model, y)
@variable(model, z[1:10]);

# ### Constraint references

# While calling the `@constraint` macro, we can also set up a constraint
# reference. Such a reference is useful for obtaining additional information
# about the constraint, such as its dual solution.

@constraint(model, con, x <= 4)

# ### [Containers](@id tutorial_constraint_container)

# Just as we had containers for variables, JuMP also provides `Arrays`,
# `DenseAxisArrays`, and `SparseAxisArrays` for storing collections of
# constraints. Examples for each container type are given below.

# #### Arrays

@constraint(model, [i = 1:3], i * x <= i + 1)

# #### DenseAxisArrays

@constraint(model, [i = 1:2, j = 2:3], i * x <= j + 1)

# #### SparseAxisArrays

@constraint(model, [i = 1:2, j = 1:2; i != j], i * x <= j + 1)

# ### Constraints in a loop

# We can add constraints using regular Julia loops

for i in 1:3
    @constraint(model, 6x + 4y >= 5i)
end

# or use for each loops inside the `@constraint` macro.

@constraint(model, [i in 1:3], 6x + 4y >= 5i)

# We can also create constraints such as $\sum _{i = 1}^{10} z_i \leq 1$

@constraint(model, sum(z[i] for i in 1:10) <= 1)

# ## Objective functions

# While the recommended way to set the objective is with the [`@objective`](@ref)
# macro, the functions [`set_objective_sense`](@ref) and [`set_objective_function`](@ref)
# provide an equivalent lower-level interface.

using GLPK

model = Model(GLPK.Optimizer)
@variable(model, x >= 0)
@variable(model, y >= 0)
set_objective_sense(model, MOI.MIN_SENSE)
set_objective_function(model, x + y)

optimize!(model)

#-

objective_value(model)

# To query the objective function from a model, we use the [`objective_sense`](@ref),
# [`objective_function`](@ref), and [`objective_function_type`](@ref) functions.

objective_sense(model)

#-

objective_function(model)

#-

objective_function_type(model)

# ## Vectorized syntax

# We can also add constraints and an objective to JuMP using vectorized linear
# algebra. We'll illustrate this by solving an LP in standard form i.e.

# ```math
# \begin{aligned}
# & \min & c^T x \\
# & \;\;\text{s.t.} & A x = b \\
# & & x \succeq 0 \\
# & & x \in \mathbb{R}^n
# \end{aligned}
# ```

vector_model = Model(GLPK.Optimizer)

A = [
    1 1 9 5
    3 5 0 8
    2 0 6 13
]

b = [7; 3; 5]

c = [1; 3; 5; 2]

@variable(vector_model, x[1:4] >= 0)
@constraint(vector_model, A * x .== b)
@objective(vector_model, Min, c' * x)

optimize!(vector_model)

#-

objective_value(vector_model)

