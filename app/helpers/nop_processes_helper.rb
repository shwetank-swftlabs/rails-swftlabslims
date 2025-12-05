module NopProcessesHelper
  def V_H_c_H(nop_process)
    if nop_process.previous_process.present?
      "-"
    else
      "#{nop_process.final_nitric_acid_amount} #{nop_process.nitric_acid_units} / #{nop_process.final_nitric_acid_molarity} mol/L"
    end
  end

  def V_H_prime_c_H_prime(nop_process)
    if nop_process.previous_process.present?
      "#{nop_process.additional_nitric_acid_amount} #{nop_process.nitric_acid_units} / #{nop_process.additional_nitric_acid_molarity} mol/L"
    else
      "-"
    end
  end

  def V_H_double_prime_c_H_double_prime(nop_process)
    if nop_process.previous_process.present?
      "#{nop_process.final_nitric_acid_amount} #{nop_process.nitric_acid_units}"
    else
      "-"
    end
  end


  def V_cE_pH_cE(nop_process)
    if nop_process.concentrated_effluent_generated_amount.present?
      "#{nop_process.concentrated_effluent_generated_amount} #{nop_process.nitric_acid_units.upcase} / #{nop_process.concentrated_effluent_generated_ph}"
    else
      "Data not recorded"
    end
  end
end

