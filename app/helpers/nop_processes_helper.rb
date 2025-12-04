module NopProcessesHelper
  def V_H(nop_process)
    if nop_process.previous_process.present?
      "N/A"
    else
      "#{nop_process.final_nitric_acid_amount} #{nop_process.nitric_acid_units}"
    end
  end

  def c_H(nop_process)
    if nop_process.previous_process.present?
      "N/A"
    else
      "#{nop_process.final_nitric_acid_molarity} mol/L"
    end
  end

  def V_H_prime(nop_process)
    if nop_process.previous_process.present?
      "#{nop_process.additional_nitric_acid_amount} #{nop_process.nitric_acid_units}"
    else
      "N/A"
    end
  end

  def c_H_prime(nop_process)
    if nop_process.previous_process.present?
      "#{nop_process.additional_nitric_acid_molarity} mol/L"
    else
      "N/A"
    end
  end

  def V_H_double_prime(nop_process)
    if nop_process.previous_process.present?
      "#{nop_process.final_nitric_acid_amount} #{nop_process.nitric_acid_units}"
    else
      "N/A"
    end
  end

  def c_H_double_prime(nop_process)
    if nop_process.previous_process.present?
      "#{nop_process.final_nitric_acid_molarity} mol/L"
    else
      "N/A"
    end
  end

  def V_cE(nop_process)
    if nop_process.concentrated_effluent_generated_amount.present?
      "#{nop_process.concentrated_effluent_generated_amount} #{nop_process.nitric_acid_units.upcase}"
    else
      "Data N/A"
    end
  end

  def pH_cE(nop_process)
    if nop_process.concentrated_effluent_generated_ph.present?
      "#{nop_process.concentrated_effluent_generated_ph}"
    else
      "Data N/A"
    end
  end
end

