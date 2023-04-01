extends Node2D

var l = 1.0/(pow(2.0,0.5))
var m1 = 1.0
var m2 = 28.0
var mu = 1.0
var G = 6.6743e-11
var r_0 = 0.8
var phi_0 = 0.8
var P_r_0 = 1.0
var k = 1.0
var time_step = 0
var velocity_array = []
var r_array = []
var draw_scale = 50.0

func _ready():
	#Show orbit
	draw_points()
	update_sliders()

func _process(delta):
	
	
	
	if (time_step < $OrbitPlot.points.size()):
		$Body.global_position = $OrbitPlot.points[time_step]
		draw_current_energy(r_array[time_step], velocity_array[time_step].x, velocity_array[time_step].y)
	else:
		time_step = 0
	
	if ($Camera2D.following == true):
		$BodyLine.visible = true
		$BodyLine.points = [Vector2.ZERO, Vector2.ZERO]
		$BodyLine.points[1] = $Body.global_position
	else:
		$BodyLine.visible = false

func effective_potential(_r):
	var eff_pot = ((l*l) / (2*mu*_r*_r)) - ((k)/(_r))
	return eff_pot

func derivates(_t, x_array):
	var _r = x_array[0]
	var _phi = x_array[1] 
	var _P_r = x_array[2]
	var r_dot = _P_r / mu
	var phi_dot = l / (mu * _r**2)
	var P_r_dot = l**2 / (mu * _r**3) - k / (_r*_r)
	return PackedFloat64Array([r_dot, phi_dot, P_r_dot])

func runge_kutta_4(t0, tf, dt, _r, _phi, _P_r):
	var t_array = []
	var scale = 1000.0
	for t in range(t0*scale, tf*scale, dt*scale):
		t_array.append(t/scale)
	# Perform numerical integration using the Runge-Kutta method
	var x = [_r, _phi, _P_r]
	var sol_array = []
	for i in range(len(t_array)-1):
		var k1 = array_mult(dt, derivates(t0, x))
		var x_mod_2 = [x[0] + 0.5*k1[0]*dt, x[1] + 0.5*k1[1]*dt, x[2] + 0.5*k1[2]*dt]
		var k2 = array_mult(dt, derivates(t0 + 0.5*dt, x_mod_2))
		var x_mod_3 = [x[0] + 0.5*k2[0]*dt, x[1] + 0.5*k2[1]*dt, x[2] + 0.5*k2[2]*dt]
		var k3 = array_mult(dt, derivates(t0 + 0.5*dt, x_mod_3))
		var x_mod_4 = [x[0] + k3[0]*dt, x[1] + k3[1]*dt, x[2] + k3[2]*dt]
		var k4 = array_mult(dt, derivates(t0 + dt, x_mod_4))
		x = [x[0] + (k1[0] + 2*k2[0] + 2*k3[0] + k4[0]) / 6 * dt,  
			x[1] + (k1[1] + 2*k2[1] + 2*k3[1] + k4[1]) / 6 * dt, 
			x[2] + (k1[2] + 2*k2[2] + 2*k3[2] + k4[2]) / 6 * dt]
		sol_array.append(x)
		t0 = t_array[i]
	return sol_array

func array_mult(mult, array):
	for i in len(array): # in GDScript you can skip the range()
		array[i] *= mult
	return array

func draw_current_energy(_r, _vr, _vphi):
	var E = 0.5 * mu * _vr*_vr + 0.5* mu * _r*_r*_vphi*_vphi - k/_r
	$CanvasLayer/EnergyPlot/EffPot/CurrentEnergy.position = Vector2(_r, -E)*draw_scale
	$CanvasLayer/EnergyPlot/EffPot/CurrentPotential.position = Vector2(_r, -effective_potential(_r))*draw_scale

func draw_points():
	time_step = 0.0
	$OrbitPlot.points = []
	var sol_array = runge_kutta_4(0.0, 1000.0, 0.03, r_0, phi_0, P_r_0)
	# Extract the position and velocity from the solution
	var step = 25.0
	velocity_array = []
	r_array = []
	
	for i in len(sol_array)/step:
		var k = i*step
		var r = sol_array[k][0]
		var phi = sol_array[k][1]
		var v_r = sol_array[k][2]/mu
		var v_phi = l/(mu * r*r)
		
		r_array.append(r)
		velocity_array.append(Vector2(v_r,v_phi))
		# Convert to Cartesian coordinates
		var _x = r * cos(phi)
		var _y = r * sin(phi)
		$OrbitPlot.add_point(Vector2(_x,_y)*draw_scale)
		
	#Initial potential
	draw_potential(velocity_array[0].x, velocity_array[0].y)

func draw_potential(_vr, _vphi):
	$CanvasLayer/EnergyPlot/EffPot.points = []
	#Plot potential
	for k in range(20.0, 2800.0, 1.0):
		var r = k/100.0
		$CanvasLayer/EnergyPlot/EffPot.add_point(Vector2(r, -effective_potential(r))*draw_scale)
	
	var E = 0.5 * mu * _vr*_vr + 0.5* mu * r_0*r_0*_vphi*_vphi - k/r_0
	$CanvasLayer/EnergyPlot/EffPot/EnergyLine.points = []
	$CanvasLayer/EnergyPlot/EffPot/EnergyLine.add_point(Vector2(0.0,-E) * draw_scale)
	$CanvasLayer/EnergyPlot/EffPot/EnergyLine.add_point(Vector2(200.0, -E) * draw_scale)
	
	$CanvasLayer/EnergyPlot/EffPot/ZeroLine.add_point(Vector2(0.0, 0.0) * draw_scale)
	$CanvasLayer/EnergyPlot/EffPot/ZeroLine.add_point(Vector2(200.0, 0.0) * draw_scale)
	

func update_sliders():
	$CanvasLayer/SliderUI/KSlider.value = k
	$CanvasLayer/SliderUI/MuSlider.value = mu
	$CanvasLayer/SliderUI/Lslider.value = l
	$CanvasLayer/SliderUI/P_r_slider.value = P_r_0
	$CanvasLayer/SliderUI/RSlider.value = r_0

func _on_lslider_drag_ended(value_changed):
	l = $CanvasLayer/SliderUI/Lslider.value
	draw_points()


func _on_p_r_slider_drag_ended(value_changed):
	P_r_0 =$CanvasLayer/SliderUI/P_r_slider.value
	draw_points()


func _on_r_slider_drag_ended(value_changed):
	r_0 = $CanvasLayer/SliderUI/RSlider.value
	draw_points()


func _on_advance_time_timeout():
	time_step += 1


func _on_mu_slider_drag_ended(value_changed):
	mu = $CanvasLayer/SliderUI/MuSlider.value
	draw_points()


func _on_k_slider_drag_ended(value_changed):
	k = $CanvasLayer/SliderUI/KSlider.value
	draw_points()


func _on_orbita_circular_pressed():
	r_0 = l*l / (mu*k)
	P_r_0 = 0.0
	update_sliders()
	draw_points()


func _on_orbita_eliptica_pressed():
	mu = 1.0
	r_0 = 0.6
	k = 1.0
	P_r_0 = 0.1
	l = 1.0
	update_sliders()
	draw_points()


func _on_orbita_eliptica_2_pressed():
	mu = 1.0
	r_0 = 1.346
	k = 1.0
	P_r_0 = 0.938
	l = 0.639
	update_sliders()
	draw_points()


func _on_orbita_abierta_pressed():
	mu = 1.0
	r_0 = 0.346
	k = 1.0
	P_r_0 = 1.711
	l = 0.639
	update_sliders()
	draw_points()
