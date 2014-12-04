#include <avr/io.h>

//-----------------------------------------
//-----------------MATRIX------------------
//-----------------------------------------

class Matrix
{

	private:
		volatile uint8_t *m_rowPort;
		volatile uint8_t *m_colPort;
	
	public:
		Matrix(volatile uint8_t *rowPort, volatile uint8_t *rowDDR, volatile uint8_t *colPort, volatile uint8_t *colDDR);
		~Matrix() { m_rowPort = 0; m_colPort = 0; }
		
		void setLED(uint8_t x, uint8_t y);
};

Matrix::Matrix(volatile uint8_t *rowPort, volatile uint8_t *rowDDR, volatile uint8_t *colPort, volatile uint8_t *colDDR)
{
	m_rowPort = rowPort;
	m_colPort = colPort;
	*rowDDR = 0xFF;
	*colDDR = 0xFF;
}

void Matrix::setLED(uint8_t x, uint8_t y)
{
	*m_rowPort = 1 << (x - 1);
	*m_colPort = 0xFF;
	*m_colPort &= ~(1 << (y - 1));
}

//-----------------------------------------
//-----------------------------------------
//-----------------------------------------

//-----------------------------------------
//-----------------BUTTON------------------
//-----------------------------------------
class Button
{
	private:
		bool m_pressed;
		
	public:
		Button(volatile uint8_t *port, volatile uint8_t *DDR);
		~Button() {}
		
		void control(void )
}
//-----------------------------------------
//-----------------------------------------
//-----------------------------------------

int main()
{

	Matrix matrix(&PORTA, &DDRA, &PORTD, &DDRD);
	
	matrix.setLED(2,2);
	
}