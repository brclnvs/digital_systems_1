#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vproj5_bruno_5.h"
#include <iostream>

enum TestPhase {
    INITIAL_RESET_START,
    INITIAL_RESET_END,
    WAIT_FOR_TEST1,
    RUN_TEST1,
    SAMPLE_TEST1,
    WAIT_FOR_TEST2,
    RUN_TEST2,
    SAMPLE_TEST2,
    FINAL_RESET_START,
    FINAL_RESET_END,
    SIM_DONE
};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vproj5_bruno_5* dut = new Vproj5_bruno_5;
    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 99);
    m_trace->open("waveform.vcd");

    vluint64_t sim_time = 0;
    vluint64_t reset_end_time = 0;
    TestPhase test_phase = INITIAL_RESET_START;

    dut->reset = 1;
    dut->INI = 0;
    dut->A = 0;
    dut->B = 0;

    while (sim_time < 5000 && !Verilated::gotFinish()) {
        
        dut->clk = 0;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time += 5;

        switch(test_phase) {
            case INITIAL_RESET_START:
                if (sim_time >= 10) {
                    std::cout << "[" << sim_time << " ns] Applying initial reset pulse..." << std::endl;
                    dut->reset = 0;
                    dut->eval();
                    test_phase = INITIAL_RESET_END;
                }
                break;

            case INITIAL_RESET_END:
                if (sim_time >= 30) {
                    dut->reset = 1;
                    dut->eval();
                    std::cout << "[" << sim_time << " ns] Initial reset released. Starting tests." << std::endl;
                    test_phase = WAIT_FOR_TEST1;
                }
                break;

            case WAIT_FOR_TEST1:
                if (sim_time >= 50) {
                    dut->A = 100;
                    dut->B = 10;
                    std::cout << "[" << sim_time << " ns] Test 1: A=" << (int)dut->A << ", B=" << (int)dut->B << std::endl;
                    dut->INI = 1;
                    test_phase = RUN_TEST1;
                }
                break;

            case RUN_TEST1:
                dut->INI = 0;
                if (dut->P == 1) {
                    test_phase = SAMPLE_TEST1;
                }
                break;
            
            case SAMPLE_TEST1:
                std::cout << "[" << sim_time << " ns] Division 1 complete (P=1 detected)." << std::endl;
                std::cout << "  Result: R=" << (int)dut->R << ", REM=" << (int)dut->REM << std::endl;
                test_phase = WAIT_FOR_TEST2;
                break;
            
            case WAIT_FOR_TEST2:
                 if (sim_time >= 310) {
                    dut->A = 27;
                    dut->B = 4;
                    std::cout << "[" << sim_time << " ns] Test 2: A=" << (int)dut->A << ", B=" << (int)dut->B << std::endl;
                    dut->INI = 1;
                    test_phase = RUN_TEST2;
                }
                break;

            case RUN_TEST2:
                dut->INI = 0;
                if (dut->P == 1) {
                    test_phase = SAMPLE_TEST2;
                }
                break;
            
            case SAMPLE_TEST2:
                std::cout << "[" << sim_time << " ns] Division 2 complete (P=1 detected)." << std::endl;
                std::cout << "  Result: R=" << (int)dut->R << ", REM=" << (int)dut->REM << std::endl;
                test_phase = FINAL_RESET_START;
                break;
            
            case FINAL_RESET_START:
                std::cout << "[" << sim_time << " ns] All tests finished. Applying final reset..." << std::endl;
                dut->reset = 0;
                dut->eval();
                reset_end_time = sim_time + 20;
                test_phase = FINAL_RESET_END;
                break;

            case FINAL_RESET_END:
                if (sim_time >= reset_end_time) {
                    dut->reset = 1;
                    dut->eval();
                    std::cout << "[" << sim_time << " ns] Final reset complete. Simulation will idle." << std::endl;
                    test_phase = SIM_DONE;
                }
                break;

            case SIM_DONE:
                break;
        }
        
        dut->clk = 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time += 5;
    }

    m_trace->close();
    delete dut;
    return 0;
}
