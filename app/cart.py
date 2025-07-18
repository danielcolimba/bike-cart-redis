from fastapi import APIRouter, HTTPException
import redis
import os
from pydantic import BaseModel
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter()

# Configuración de Redis con variables de entorno
r = redis.Redis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=int(os.getenv("REDIS_PORT", 6379)),
    decode_responses=True,
    socket_connect_timeout=5,
    socket_timeout=5,
    retry_on_timeout=True
)

class CartItem(BaseModel):
    user_id: str
    product_id: str
    quantity: int

@router.get("/health")
def health_check():
    """Health check endpoint para Docker"""
    try:
        # Verificar conexión a Redis
        r.ping()
        return {
            "status": "healthy",
            "service": "cart-redis-service",
            "version": "1.0.0",
            "redis": "connected"
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=503, detail="Service unhealthy")

@router.post("/cart/add")
def add_to_cart(item: CartItem):
    try:
        key = f"cart:{item.user_id}"
        r.hincrby(key, item.product_id, item.quantity)
        logger.info(f"Added {item.quantity} of product {item.product_id} to cart for user {item.user_id}")
        return {"message": "Producto agregado al carrito", "success": True}
    except Exception as e:
        logger.error(f"Error adding to cart: {e}")
        raise HTTPException(status_code=500, detail="Error al agregar producto al carrito")

@router.get("/cart/{user_id}")
def get_cart(user_id: str):
    try:
        key = f"cart:{user_id}"
        cart = r.hgetall(key)
        return {"cart": cart, "user_id": user_id}
    except Exception as e:
        logger.error(f"Error getting cart: {e}")
        raise HTTPException(status_code=500, detail="Error al obtener carrito")

@router.delete("/cart/{user_id}/{product_id}")
def remove_item(user_id: str, product_id: str):
    try:
        key = f"cart:{user_id}"
        result = r.hdel(key, product_id)
        if result:
            logger.info(f"Removed product {product_id} from cart for user {user_id}")
            return {"message": "Producto eliminado", "success": True}
        else:
            return {"message": "Producto no encontrado en el carrito", "success": False}
    except Exception as e:
        logger.error(f"Error removing from cart: {e}")
        raise HTTPException(status_code=500, detail="Error al eliminar producto del carrito")
