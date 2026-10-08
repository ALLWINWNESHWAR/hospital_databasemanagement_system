
-- creating the tables
/*

                       DEPARTMENT
                           │
                           │ 1:N
                           ▼
                        DOCTOR
                       /      \
                    1:N        1:N
                     /          \
                    ▼            ▼
               APPOINTMENT   PRESCRIPTION
                  ▲  │           │
                  │  │           │ 1:N
                  │  │           ▼
                  │  │     PRESCRIPTION_ITEM
                  │  │          ▲
                  │  │          │ N:1
                  │  │          │
               PATIENT        MEDICINE
                  │
                  │ 1:N
                  ▼
                 BILL
                  │
                  │ 1:N
                  ▼
               PAYMENT


                 ROOM
                  │
                  │
             [used for
              hospital
              room data]


