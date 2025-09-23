import asyncio
import logging
import os
from typing import Final

from telegram import Update
from telegram.ext import (Application, ApplicationBuilder, CommandHandler,
                          ContextTypes, MessageHandler, filters)

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)
logger = logging.getLogger(__name__)

BOT_TOKEN_ENV: Final[str] = "BOT_TOKEN"


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Send a welcome message with basic instructions."""
    user_first_name = update.effective_user.first_name if update.effective_user else "there"
    message = (
        "Halo {name}!\n\n" "Kirim pesan teks apa pun dan bot akan meneruskannya kembali."
    ).format(name=user_first_name)
    await update.message.reply_text(message)


async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """List available commands."""
    message = (
        "Perintah yang tersedia:\n"
        "- /start untuk memulai percakapan\n"
        "- /help untuk menampilkan pesan ini\n"
        "- /ping untuk uji respons"
    )
    await update.message.reply_text(message)


async def ping(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Simple health check command."""
    await update.message.reply_text("pong")


async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Echo user messages back to them."""
    if update.message and update.message.text:
        await update.message.reply_text(update.message.text)


def main() -> None:
    token = os.getenv(BOT_TOKEN_ENV)
    if not token:
        raise RuntimeError(
            f"Environment variable '{BOT_TOKEN_ENV}' is required for the Telegram bot token."
        )

    application: Application = ApplicationBuilder().token(token).build()

    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(CommandHandler("ping", ping))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo))

    logger.info("Starting Telegram bot polling loop")
    application.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
