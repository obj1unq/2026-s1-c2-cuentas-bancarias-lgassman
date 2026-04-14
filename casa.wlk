object casa {
    
    var cuenta = cuentaCorriente
    var gastos = 0
    var property reparaciones = 0
    var property viveres = 0
    var mantenimiento = minimoIndispensable

    const viveresMinimos = 40
    
    method mantenimiento(_mantenimiento) {
        mantenimiento = _mantenimiento
    }
    method viveresSuficientes() {
        return viveres >= viveresMinimos
    }
    method hayQueReparar() {
        return reparaciones > 0
    }
    method enOrden() {
        return self.viveresSuficientes() and not self.hayQueReparar()
    }
    method reparar() {
        self.gastar(reparaciones)
        reparaciones = 0
    }
    method repararSiHayPlata() {
        if (reparaciones <= cuenta.saldo()) {
            self.reparar()
        }
    }

    method completarMinimo(calidad) {
        self.completarViveres(viveresMinimos, calidad)
    }

    method completarMaximo(calidad) {
        self.completarViveres(100, calidad)
    }
    method completarViveres(valor, calidad) {
        if (viveres < valor) { //Esta bien por requerimiento no hacer nada si no se cumple la condicion
            self.comprar(valor - viveres, calidad)
        }
    }

    method comprar(porcentaje, calidad) {
        self.validarComprar(porcentaje)
        self.gastar(porcentaje * calidad)
        viveres = viveres + porcentaje
    }
    method validarComprar(porcentaje) {
        if (not self.puedeComprar(porcentaje)) {
            self.error("No se puede comprar " + porcentaje)
        }
    }
    method puedeComprar(porcentaje) {
        return viveres + porcentaje <= 100
    }
    method romper(monto) {
        reparaciones = reparaciones + monto
    }

    method cuenta(_cuenta) {
        cuenta = _cuenta
    }

    
    method cuenta() {
        return cuenta
    }

    method gastar(dinero) {
        cuenta.extraer(dinero)
        gastos = gastos + dinero
    }

    method gastos() {
        return gastos
    }

    method nuevoMes() {
        mantenimiento.mantener(self)
        gastos = 0
    }
}


object cuentaCorriente {

    var property saldo = 0

    method extraer(dinero) {
        saldo = saldo - dinero
    }
    method depositar(dinero) {
        saldo = saldo + dinero
    }

}


object cuentaConGastos {

    var property saldo = 0
    var property costoOperacion = 20

    method extraer(dinero) {
        saldo = saldo - dinero
    }
    method depositar(dinero) {
        self.validarDeposito(dinero)
        saldo = saldo + dinero - costoOperacion
    }
    method validarDeposito(dinero) {
        if (not self.puedeDepositar(dinero)) {
            self.error("No se puede depositar " + dinero)
        }
    }
    method puedeDepositar(dinero) {
        return dinero >= costoOperacion
    }

}

object cuentaCombinada {
    var property cuentaPrimaria = cuentaCorriente
    var property cuentaSecundaria = cuentaConGastos

    method saldo() {
        return self.saldoPrimaria() + self.saldoSecundaria()
    }

    method saldoPrimaria() {
        return self.saldo(cuentaPrimaria)
    }

    method saldoSecundaria() {
        return self.saldo(cuentaSecundaria)
    }

    method saldo(cuenta) {
        return 0.max(cuenta.saldo())
    }

    method depositar(dinero) {
        cuentaPrimaria.depositar(dinero)
    }

    method extraer(dinero) {
        self.validarExtraer(dinero)
        const extraccionPrimaria =  dinero.min(self.saldoPrimaria())
        cuentaPrimaria.extraer(extraccionPrimaria)
        if (extraccionPrimaria < dinero) 
            cuentaSecundaria.extraer(dinero - extraccionPrimaria)
    }
    method validarExtraer(dinero) {
        if (not self.puedeExtraer(dinero)) {
            self.error("No se puede extraer " + dinero)
        }
    }
    method puedeExtraer(dinero) {
        return dinero <= self.saldo()
    }
}

object minimoIndispensable {
    var calidad = 1

    method calidad(_calidad) {
        calidad = _calidad
    }

    method mantener(casa) {
        casa.completarMinimo(calidad)
    }

}

object full {
    const calidad = 5
    method mantener(casa) {
        if (casa.enOrden()) {
            casa.completarMaximo(calidad)
        }
        else {
            casa.completarMinimo(calidad)
            casa.repararSiHayPlata()
        }
    }


}