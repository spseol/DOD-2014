#include <avr/io.h>

//-----------------------------------------
//-----------------MATRIX------------------
//-----------------------------------------

class Matrix
{

	private:
		volatile uint8_t *m_rowPort;
		volatile uint8_t *m_colPort;
		
		unsigned char m_x;
		unsigned char m_y;
		
		static const unsigned char m_size = 8;
	
	public:
		enum Direction { Top, Right, Bottom, Left };
		Matrix(volatile uint8_t *rowPort, volatile uint8_t *rowDDR, volatile uint8_t *colPort, volatile uint8_t *colDDR);
		~Matrix() { m_rowPort = 0; m_colPort = 0; }
		
		void setLED(uint8_t x, uint8_t y);
		void move(Matrix::Direction dir);
};

Matrix::Matrix(volatile uint8_t *rowPort, volatile uint8_t *rowDDR, volatile uint8_t *colPort, volatile uint8_t *colDDR)
{
	m_rowPort = rowPort;
	m_colPort = colPort;
	*rowDDR = 0xFF;
	*colDDR = 0xFF;
	
	setLED(0, 0);
}

void Matrix::setLED(uint8_t x, uint8_t y)
{
	*m_rowPort = 1 << y;
	*m_colPort = 0xFF;
	*m_colPort &= ~(1 << x);
	
	m_x = x;
	m_y = y;
}

void Matrix::move(Matrix::Direction dir)
{
	switch(dir)
	{
		case Matrix::Top:
			(m_y == 0) ?setLED(m_x, m_size - 1) :setLED(m_x, m_y - 1);
			break;
		
		case Matrix::Right:
			(m_x == m_size - 1) ?setLED(0, m_y) :setLED(m_x + 1, m_y);
			break;

		case Matrix::Bottom:
			(m_y == m_size - 1) ?setLED(m_x, 0) :setLED(m_x, m_y + 1);
			break;
		
		case Matrix::Left:
			(m_x == 0) ?setLED(m_size - 1, m_y) :setLED(m_x - 1, m_y);
			break;
	}
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
		uint8_t m_pinNumber;
		volatile uint8_t *m_pin;
		bool m_pressed;
		
	public:
		Button(uint8_t pinNumber, volatile uint8_t *pin, volatile uint8_t *port, volatile uint8_t *DDR);
		~Button() {}
		
		bool control();
};

Button::Button(uint8_t pinNumber, volatile uint8_t *pin, volatile uint8_t *port, volatile uint8_t *DDR)
{
	//set
	*DDR &= ~(1 << pinNumber);
	*port |= 1 << pinNumber;
	
	m_pinNumber = pinNumber;
	m_pin = pin;
}

bool Button::control()
{
	if(bit_is_clear(*m_pin, m_pinNumber))
	{
		if(!m_pressed) 
		{
			m_pressed = true;
			return true;
		}
	}
	else
		m_pressed = false;
	return false;
}
//-----------------------------------------
//-----------------------------------------
//-----------------------------------------

/*void doo(Matrix &m, Matrix::Direction dir)
{
	m.move(dir);
}*/

int main()
{
DDRB |= 1;
	Matrix matrix(&PORTA, &DDRA, &PORTD, &DDRD);
	
	//matrix.setLED(2,2);
	Button top(0, &PINB, &PORTB, &DDRB);
	Button right(1, &PINB, &PORTB, &DDRB);
	Button bottom(2, &PINB, &PORTB, &DDRB);
	Button left(3, &PINB, &PORTB, &DDRB);

	while(true) 
	{
		if(top.control())
			matrix.move(Matrix::Top);
			
		else if(right.control())
			matrix.move(Matrix::Right);
		
		else if(bottom.control())
			matrix.move(Matrix::Bottom);
		
		else if(left.control())
			matrix.move(Matrix::Left);
	}
	
}